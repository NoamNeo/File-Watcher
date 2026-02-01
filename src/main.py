import os
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class TemplateWatcher(FileSystemEventHandler):
    def __init__(self, watch_dir, templates):
        self.watch_dir = Path(watch_dir)
        self.templates = templates
