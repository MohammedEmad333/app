"""Print a concise line-coverage summary from Flutter LCOV data."""
import pathlib
import sys


def summarize(path):
    found = hit = 0
    for raw in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
        if not raw.startswith("DA:"):
            continue
        parts = raw[3:].split(",")
        if len(parts) < 2:
            raise ValueError(f"Malformed LCOV DA entry: {raw}")
        count = int(parts[1])
        found += 1
        hit += count > 0
    if not found:
        raise ValueError("LCOV contains no DA line records")
    return hit, found


def main():
    try:
        hit, total = summarize(sys.argv[1] if len(sys.argv) > 1 else "coverage/lcov.info")
    except (OSError, ValueError) as exc:
        print(f"Invalid coverage report: {exc}", file=sys.stderr)
        return 1
    print(f"Flutter line coverage: {hit}/{total} ({hit / total * 100:.1f}%)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
