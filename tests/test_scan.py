"""Tests for scripts/scan.py — run with: python3 -m pytest tests/"""
import json
import subprocess
import sys
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
SCAN = REPO / "scripts" / "scan.py"

sys.path.insert(0, str(REPO / "scripts"))
from scan import scan, compile_term  # noqa: E402


WORDLIST = {
    "categories": {
        "brands": {
            "suggested_replacement": "a leading tool",
            "terms": ["Wind", "C++"],
        },
        "metrics": {
            "suggested_replacement": "to be evaluated",
            "terms": ["regex:\\d+\\s*并发", "regex:\\d+(\\.\\d+)?\\s*(秒|毫秒|ms)"],
        },
    }
}


def hits_for(text, wordlist=WORDLIST):
    hits, _ = scan(text, wordlist)
    return hits


def test_literal_case_insensitive():
    matched = {h["matched"] for h in hits_for("wind 平台、WIND 资讯、Wind 终端")}
    assert matched == {"wind", "WIND", "Wind"}


def test_literal_fullwidth_matches():
    # NFKC folds full-width Latin to half-width
    assert len(hits_for("对接Ｗｉｎｄ数据源")) == 1


def test_literal_metacharacters_are_literal():
    hits = hits_for("使用 C++ 开发；C 语言不算，CSS 也不算")
    assert len(hits) == 1
    assert hits[0]["matched"] == "C++"


def test_regex_prefix_matches():
    hits = hits_for("系统支持1800并发，响应时间3秒内完成")
    assert {h["matched"] for h in hits} == {"1800并发", "3秒"}


def test_cjk_adjacent_number_matches():
    # the old \b-based example silently missed this
    assert len(hits_for("延迟低于1.5秒。", )) == 1


def test_invalid_regex_warns_not_crashes():
    wl = {"categories": {"bad": {"terms": ["regex:([oops"]}}}
    hits, warnings = scan("anything", wl)
    assert hits == []
    assert len(warnings) == 1 and warnings[0]["warning"] is True


def test_empty_wordlist_categories():
    hits, warnings = scan("text", {"categories": {"empty": {"terms": []}}})
    assert hits == [] and warnings == []
    hits, warnings = scan("text", {})
    assert hits == [] and warnings == []


def test_context_and_suggestion_present():
    (hit,) = hits_for("方案风格参考自 Wind 平台的设计")
    assert "Wind" in hit["context"]
    assert hit["suggested_replacement"] == "a leading tool"


def test_cli_end_to_end(tmp_path):
    doc = tmp_path / "draft.txt"
    doc.write_text("对比了 wind 与自研方案，支持1800并发。", encoding="utf-8")
    wl = tmp_path / "wordlist.yaml"
    wl.write_text(
        "categories:\n"
        "  brands:\n"
        "    suggested_replacement: x\n"
        "    terms: [Wind]\n"
        "  metrics:\n"
        "    terms: ['regex:\\d+\\s*并发']\n",
        encoding="utf-8",
    )
    out = subprocess.run(
        [sys.executable, str(SCAN), "--doc", str(doc), "--wordlist", str(wl)],
        capture_output=True, text=True, check=True,
    )
    lines = [json.loads(l) for l in out.stdout.strip().splitlines()]
    summary = lines[-1]
    assert summary["summary"] is True
    assert summary["hits"] == 2
    assert summary["terms_checked"] == 2


def test_cli_unsupported_extension_clean_error(tmp_path):
    doc = tmp_path / "draft.xyz"
    doc.write_text("x", encoding="utf-8")
    wl = tmp_path / "wl.yaml"
    wl.write_text("categories: {}\n", encoding="utf-8")
    out = subprocess.run(
        [sys.executable, str(SCAN), "--doc", str(doc), "--wordlist", str(wl)],
        capture_output=True, text=True,
    )
    assert out.returncode == 1
    err = json.loads(out.stdout.strip().splitlines()[0])
    assert "unsupported extension" in err["error"]
    assert "Traceback" not in out.stderr
