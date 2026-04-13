import yaml

with open("README.yaml") as f:
    data = yaml.safe_load(f)

# ---------- Helpers ---------- #

def safe_get(key):
    return data.get(key, "").strip()

def list_to_markdown(items, key_name="name", key_version="version"):
    if not items:
        return "N/A"
    return "\n".join(
        [f"- **{i.get(key_name)}** ({i.get(key_version, '')})" for i in items]
    )

# ---------- Sections ---------- #

intro = safe_get("intro")
about = safe_get("about")
badges_text = safe_get("badges_text")
description = safe_get("description")
usage = safe_get("usage")
extras = safe_get("extras")

# ---------- Banner (optional) ---------- #

banner = ""
if data.get("banner"):
    banner = f"""
<p align="center">
  <a href="{data['banner'].get('link', '#')}">
    <img src="{data['banner'].get('image')}" alt="Banner" />
  </a>
</p>
"""

# ---------- Badges ---------- #

badges = " ".join(
    [f"[![{b['name']}]({b['image']})]({b['url']})" for b in data.get("badges", [])]
)

# ---------- Tables ---------- #

# Prerequisites + Providers (table format)
table = ""
if data.get("prerequesties") or data.get("providers"):
    table += "| Description | Name | Version |\n"
    table += "|-------------|------|---------|\n"

    for p in data.get("prerequesties", []):
        table += f"| Prerequisite | {p.get('name')} | {p.get('version')} |\n"

    for p in data.get("providers", []):
        table += f"| Provider | {p.get('name')} | {p.get('version')} |\n"

# Module dependencies
module_deps = ""
if data.get("module_dependencies"):
    module_deps = "## 🔗 Module Dependencies\n\n"
    for m in data["module_dependencies"]:
        module_deps += f"- [{m.get('name')}]({m.get('url')}): {m.get('description')}\n"

# ---------- README ---------- #

readme = f"""{banner}

# {safe_get('name')}

{intro}

{badges_text}

{badges}

---

## 📖 About

{about}

---

## ⚙️ Prerequisites and Providers

{table}

---

## 📝 Description

{description}

---

## 🚀 Usage

{usage}

---

## 📥 Inputs and Outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

---

{module_deps}

---

{extras}
"""

# ---------- Write ---------- #

with open("README.md", "w") as f:
    f.write(readme)