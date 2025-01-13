#!/usr/bin/env python


import sys
from ctraceback import CTraceback
import os
from rich.console import Console
console = Console()
from configset import configset
from pathlib import Path
import re
from pydebugger.debug import debug
from datetime import datetime
from collections import Counter
import subprocess


class Build:
    CONFIGFILE = str(Path.cwd() / 'build.ini')
    CONFIG = configset(CONFIGFILE)

    @classmethod
    def message_tk(self, text):
        import tkinter as tk
        from tkinter import messagebox

        # Create the main application window (root)
        root = tk.Tk()
        root.withdraw()  # Hide the main window

        # Ensure the message box stays on top
        root.attributes("-topmost", True)

        # Play a beep sound
        root.bell()

        # Display a critical error message box
        messagebox.showerror("Error", "Critical error occurred!")

        # Destroy the root window after the message box is closed
        root.destroy()

    @classmethod
    def message(self, text):
        if sys.platform == 'win32':
            try:
                import win32gui
                import win32api
                import win32con

                # Play a beep and display a message box
                win32api.MessageBeep(win32con.MB_ICONEXCLAMATION)

                # Display a message box that is always on top and focused
                win32gui.MessageBox(
                    0, 
                    text.decode() if hasattr(text, 'decode') else text, 
                    "Error", 
                    win32con.MB_OK | win32con.MB_ICONHAND | win32con.MB_TOPMOST
                )
            except:
                try:
                    self.message_tk(text)
                except:
                    console.print(f"[white on red blink]ERROR:[/] [black on #FFFF00]{text}[/]")
        else:
            try:
                self.message_tk(text)
            except:
                console.print(f"[white on red blink]ERROR:[/] [black on #FFFF00]{text}[/]")

    @classmethod
    def get_date(self):
        return datetime.strftime(datetime.now(), '%Y/%m/%d %H:%M:%S.%f')

    @classmethod
    def remove_duplicate_words(self, text):
        words = text.split()
        word_counts = Counter(words)
        return " ".join(dict.fromkeys(words))

    @classmethod
    def build(self, command = None, app = 'podman', name = None):
        app = self.CONFIG.get_config('app', 'bin') or app or 'podman'
        logfile = self.CONFIG.get_config('log', 'file') or Path.cwd() / 'build.log'
        debug(logfile = logfile)
        if not logfile.is_file:
            with open(str(logfile), 'w') as f:
                f.write(f"{self.get_date()}\n")

        command = command or self.CONFIG.get_config('command', 'build')
        debug(command = command)
        if command and list(filter(lambda k: k in command, ['podman', 'docker'])):
            command = re.sub("podman|docker", "", command, re.I)
            debug(command = command)
            if not '-t' in command:
                if not name:
                    while 1:
                        console.print(f"[bold #FFFF00]NAME:[/] ", end = '')
                        name = input()
                        debug(name = name)
                        if name:
                            break
                command = command.split("build")
                debug(command = command)
                command = command[0] + f"build -t {name} {command[1]}"
                debug(command = command)
            if not '--logfile' in command:
                command += f' --logfile "{logfile}"'
            command = f"{app} {command}"
            debug(command = command)

        else:
            if not name:
                while 1:
                    console.print(f"[bold #FFFF00]NAME:[/] ", end = '')
                    name = input()
                    debug(name = name)
                    if name:
                        break

            command = f'{app} build -t {name} --layers --logfile {logfile} .'
            debug(command = command)

        command += " ".join(sys.argv[1:])
        debug(command = command)
        command = self.remove_duplicate_words(command)
        debug(command = command)
        console.print(f"[bold #00FFFF]Build start ....[/]")
        open(str(logfile), 'a').write(f"{self.get_date()}\n")
        console.print(f"[white on red]{command}[/]")
        os.system('start cmd /k tail -f build.log')
        # a = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        a = subprocess.Popen(command.split(), stderr=subprocess.PIPE)
        err, out = a.communicate()
        print(out.decode())
        if err:
            self.message(err.decode())
        

if __name__ == '__main__':
    Build.build()