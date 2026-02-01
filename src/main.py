import os
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class TemplateWatcher(FileSystemEventHandler):
    def __init__(self, watch_dir, templates):
        self.watch_dir = Path(watch_dir)
        self.templates = templates
        self.enabled_services = {}

    def validate_services(self):
        for ext, template_path in self.templates.items():
            if template_path.exists() and template_path.stat().st_size > 0:
                self.enabled_services[ext] = True
                print(f"{ext.upper()} service online")
            else:
                self.enabled_services[ext] = False
                print(f"{ext.upper()} service offline")

    def process_file(self, file_path, template_path):
        try:
            with open(template_path, "r", encoding="utf-8") as tpl:
                content = tpl.read()
            with open(file_path, "w", encoding="utf-8") as target:
                target.write(content)
        except Exception as e:
            print(f"Error processing {file_path} : {e}")

    def on_created(self, event):
        if event.is_directory:
            return
        file_path = Path(event.src_path)
        ext = file_path.suffix.lower()
        if ext in self.enabled_services and self.enabled_services[ext]:
            if file_path.stat().st_size == 0:
                self.process_file(file_path, self.templates[ext])


if __name__ == "__main__":
    watch_dir = r"C:\dev"

    appdatta = Path(os.getenv("APPDATTA"))
    tpl_dir = appdatta / "CSS-HTML-Writer-Daemon" / "templates"

    templates = {
        ".css": tpl_dir / "css.tpl",
        ".html": tpl_dir / "html.tpl",
    }

    event_handler = TemplateWatcher(watch_dir, templates)

    observer = Observer()
    observer.schedule(event_handler, watch_dir, recursive=True)
    observer.start()
