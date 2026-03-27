#!/usr/bin/env python3
"""Export resume YAML data to JSON Resume schema (https://jsonresume.org/schema)."""

import argparse
import json
import sys
from pathlib import Path

import yaml


def convert(data: dict) -> dict:
    """Convert internal YAML resume schema to JSON Resume specification."""
    basics = data.get("basics", {})
    meta = data.get("meta", {})

    profiles = []
    for p in basics.get("profiles", []):
        profiles.append({
            "network": p.get("network", ""),
            "url": p.get("url", ""),
            "username": p.get("text", ""),
        })

    result = {
        "$schema": "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json",
        "basics": {
            "name": basics.get("name", ""),
            "label": basics.get("title", ""),
            "image": basics.get("photo", ""),
            "email": basics.get("email", ""),
            "phone": basics.get("phone", ""),
            "url": basics.get("website", {}).get("url", ""),
            "summary": (basics.get("summary", "") or "").strip(),
            "location": {
                "address": basics.get("address", {}).get("street", ""),
                "postalCode": basics.get("address", {}).get("postal_code", ""),
                "city": basics.get("address", {}).get("city", ""),
                "countryCode": "DE",
                "region": "",
            },
            "profiles": profiles,
        },
        "work": [],
        "education": [],
        "skills": [],
        "languages": [],
        "publications": [],
        "projects": [],
        "references": [],
        "meta": {
            "canonical": meta.get("footer_url", ""),
            "version": "v1.0.0",
            "lastModified": meta.get("last_updated", ""),
        },
    }

    # Work entries
    for entry in data.get("work", {}).get("entries", []):
        work_item = {
            "name": entry.get("company", ""),
            "position": entry.get("position", ""),
            "url": entry.get("url", ""),
            "startDate": entry.get("start_date", ""),
            "endDate": entry.get("end_date", ""),
            "summary": (entry.get("summary", "") or "").strip(),
            "highlights": [h.strip() for h in entry.get("highlights", [])],
        }
        result["work"].append(work_item)

    # Products → projects
    for entry in data.get("products", {}).get("entries", []):
        project_item = {
            "name": entry.get("name", ""),
            "description": (entry.get("summary", "") or "").strip(),
            "highlights": [h.strip() for h in entry.get("highlights", [])],
            "keywords": entry.get("technologies", []),
            "startDate": entry.get("start_date", ""),
            "endDate": entry.get("end_date", ""),
            "url": entry.get("url", ""),
            "type": "application",
        }
        result["projects"].append(project_item)

    # Education
    for entry in data.get("education", {}).get("entries", []):
        edu_item = {
            "institution": entry.get("institution", ""),
            "url": entry.get("url", ""),
            "area": entry.get("field", ""),
            "studyType": entry.get("degree", ""),
            "startDate": entry.get("start_date", ""),
            "endDate": entry.get("end_date", ""),
        }
        result["education"].append(edu_item)

    # Skills — group by label, merge keywords per level
    seen_labels: dict[str, dict] = {}
    for cat in data.get("skills", {}).get("categories", []):
        label = cat.get("label", "")
        level = cat.get("level", "")
        keywords = cat.get("keywords", [])
        if label not in seen_labels:
            seen_labels[label] = {"name": label, "level": level, "keywords": list(keywords)}
        else:
            seen_labels[label]["keywords"].extend(keywords)
    result["skills"] = list(seen_labels.values())

    # Languages
    for entry in data.get("languages", {}).get("entries", []):
        result["languages"].append({
            "language": entry.get("language", ""),
            "fluency": entry.get("fluency", ""),
        })

    # Publications
    for entry in data.get("publications", {}).get("entries", []):
        result["publications"].append({
            "name": entry.get("title", ""),
            "publisher": entry.get("publisher", ""),
            "releaseDate": str(entry.get("date", "")),
            "summary": (entry.get("description", "") or "").strip(),
        })

    # References — collect all recommendations
    for work_entry in data.get("work", {}).get("entries", []):
        for rec in work_entry.get("recommendations", []):
            quote = (rec.get("quote", "") or "").strip()
            if quote:
                result["references"].append({
                    "name": f"{rec.get('author', '')} — {rec.get('role', '')}",
                    "reference": quote,
                })

    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("data_file", help="Path to resume YAML data file")
    parser.add_argument("output_file", help="Path for JSON Resume output")
    args = parser.parse_args()

    data_path = Path(args.data_file)
    out_path = Path(args.output_file)

    if not data_path.exists():
        print(f"Error: {data_path} not found", file=sys.stderr)
        sys.exit(1)

    with data_path.open("r", encoding="utf-8") as fh:
        data = yaml.safe_load(fh)

    json_resume = convert(data)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as fh:
        json.dump(json_resume, fh, indent=2, ensure_ascii=False)

    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
