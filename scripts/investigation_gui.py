#!/usr/bin/env python3
"""
Investigation Container GUI Dashboard
A user-friendly interface for cybersecurity investigation tools
"""

import tkinter as tk
from tkinter import ttk, filedialog, scrolledtext, messagebox
import os
import subprocess
import threading
from datetime import datetime

class InvestigationGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Investigation Container - Security Analysis Tools")
        self.root.geometry("900x700")
        
        # Set up the main interface
        self.setup_gui()
        
    def setup_gui(self):
        # Create main notebook for tabs
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Document Analysis Tab
        doc_frame = ttk.Frame(notebook)
        notebook.add(doc_frame, text="Document Analysis")
        self.setup_document_tab(doc_frame)
        
        # URL Investigation Tab
        url_frame = ttk.Frame(notebook)
        notebook.add(url_frame, text="URL Investigation")
        self.setup_url_tab(url_frame)
        
        # File Browser Tab
        browser_frame = ttk.Frame(notebook)
        notebook.add(browser_frame, text="File Browser")
        self.setup_browser_tab(browser_frame)
        
        # Results Tab
        results_frame = ttk.Frame(notebook)
        notebook.add(results_frame, text="Results")
        self.setup_results_tab(results_frame)
        
    def setup_document_tab(self, parent):
        # Title
        title = ttk.Label(parent, text="Document Analysis", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # File selection
        file_frame = ttk.Frame(parent)
        file_frame.pack(fill="x", padx=20, pady=10)
        
        ttk.Label(file_frame, text="Select Document:").pack(anchor="w")
        
        path_frame = ttk.Frame(file_frame)
        path_frame.pack(fill="x", pady=5)
        
        self.doc_path_var = tk.StringVar()
        path_entry = ttk.Entry(path_frame, textvariable=self.doc_path_var, width=60)
        path_entry.pack(side="left", fill="x", expand=True)
        
        browse_btn = ttk.Button(path_frame, text="Browse", command=self.browse_document)
        browse_btn.pack(side="right", padx=(5, 0))
        
        # Analysis options
        options_frame = ttk.LabelFrame(parent, text="Analysis Options")
        options_frame.pack(fill="x", padx=20, pady=10)
        
        self.basic_analysis = tk.BooleanVar(value=True)
        self.strings_analysis = tk.BooleanVar(value=True)
        self.metadata_analysis = tk.BooleanVar(value=True)
        
        ttk.Checkbutton(options_frame, text="Basic file information", variable=self.basic_analysis).pack(anchor="w")
        ttk.Checkbutton(options_frame, text="Strings extraction", variable=self.strings_analysis).pack(anchor="w")
        ttk.Checkbutton(options_frame, text="Metadata analysis", variable=self.metadata_analysis).pack(anchor="w")
        
        # Action buttons
        action_frame = ttk.Frame(parent)
        action_frame.pack(fill="x", padx=20, pady=10)
        
        analyze_btn = ttk.Button(action_frame, text="Analyze Document", command=self.analyze_document)
        analyze_btn.pack(side="left", padx=(0, 10))
        
        view_btn = ttk.Button(action_frame, text="Safe View", command=self.safe_view_document)
        view_btn.pack(side="left")
        
        # Output area
        output_frame = ttk.LabelFrame(parent, text="Analysis Output")
        output_frame.pack(fill="both", expand=True, padx=20, pady=10)
        
        self.doc_output = scrolledtext.ScrolledText(output_frame, height=15)
        self.doc_output.pack(fill="both", expand=True, padx=5, pady=5)
        
    def setup_url_tab(self, parent):
        # Title
        title = ttk.Label(parent, text="URL Investigation", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # URL input
        url_frame = ttk.Frame(parent)
        url_frame.pack(fill="x", padx=20, pady=10)
        
        ttk.Label(url_frame, text="Enter URL to investigate:").pack(anchor="w")
        
        self.url_var = tk.StringVar()
        url_entry = ttk.Entry(url_frame, textvariable=self.url_var, width=80)
        url_entry.pack(fill="x", pady=5)
        
        # Action buttons
        action_frame = ttk.Frame(parent)
        action_frame.pack(fill="x", padx=20, pady=10)
        
        investigate_btn = ttk.Button(action_frame, text="Investigate URL", command=self.investigate_url)
        investigate_btn.pack(side="left", padx=(0, 10))
        
        browse_btn = ttk.Button(action_frame, text="Browse Safely (Lynx)", command=self.browse_url_safe)
        browse_btn.pack(side="left")
        
        # Output area
        output_frame = ttk.LabelFrame(parent, text="Investigation Output")
        output_frame.pack(fill="both", expand=True, padx=20, pady=10)
        
        self.url_output = scrolledtext.ScrolledText(output_frame, height=20)
        self.url_output.pack(fill="both", expand=True, padx=5, pady=5)
        
    def setup_browser_tab(self, parent):
        # Title
        title = ttk.Label(parent, text="File Browser", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # Quick access buttons
        quick_frame = ttk.Frame(parent)
        quick_frame.pack(fill="x", padx=20, pady=10)
        
        ttk.Button(quick_frame, text="Open Downloads Folder", 
                  command=lambda: self.open_folder("/home/investigator/downloads")).pack(side="left", padx=(0, 10))
        ttk.Button(quick_frame, text="Open Investigations Folder", 
                  command=lambda: self.open_folder("/home/investigator/investigations")).pack(side="left", padx=(0, 10))
        ttk.Button(quick_frame, text="Open File Manager", command=self.open_file_manager).pack(side="left")
        
        # Application launchers
        apps_frame = ttk.LabelFrame(parent, text="Applications")
        apps_frame.pack(fill="x", padx=20, pady=10)
        
        app_buttons = [
            ("Text Editor (Gedit)", lambda: self.launch_app("gedit")),
            ("LibreOffice", lambda: self.launch_app("libreoffice")),
            ("Firefox", lambda: self.launch_app("firefox")),
            ("PDF Viewer (Evince)", lambda: self.launch_app("evince")),
            ("Terminal", lambda: self.launch_app("xfce4-terminal")),
        ]
        
        for i, (text, command) in enumerate(app_buttons):
            row = i // 3
            col = i % 3
            btn = ttk.Button(apps_frame, text=text, command=command)
            btn.grid(row=row, column=col, padx=5, pady=5, sticky="ew")
            
        # Configure grid weights
        for i in range(3):
            apps_frame.columnconfigure(i, weight=1)
        
    def setup_results_tab(self, parent):
        # Title
        title = ttk.Label(parent, text="Investigation Results", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # Controls
        controls_frame = ttk.Frame(parent)
        controls_frame.pack(fill="x", padx=20, pady=10)
        
        ttk.Button(controls_frame, text="Refresh Results", command=self.refresh_results).pack(side="left", padx=(0, 10))
        ttk.Button(controls_frame, text="Open Results Folder", 
                  command=lambda: self.open_folder("/home/investigator/investigations")).pack(side="left")
        
        # Results list
        results_frame = ttk.LabelFrame(parent, text="Recent Investigations")
        results_frame.pack(fill="both", expand=True, padx=20, pady=10)
        
        # Treeview for results
        columns = ("Date", "Type", "Target", "Status")
        self.results_tree = ttk.Treeview(results_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.results_tree.heading(col, text=col)
            self.results_tree.column(col, width=150)
        
        # Scrollbar for treeview
        scrollbar = ttk.Scrollbar(results_frame, orient="vertical", command=self.results_tree.yview)
        self.results_tree.configure(yscrollcommand=scrollbar.set)
        
        self.results_tree.pack(side="left", fill="both", expand=True, padx=5, pady=5)
        scrollbar.pack(side="right", fill="y", pady=5)
        
        # Bind double-click to open result
        self.results_tree.bind("<Double-1>", self.open_result)
        
        # Load initial results
        self.refresh_results()
    
    def browse_document(self):
        filename = filedialog.askopenfilename(
            title="Select Document to Analyze",
            initialdir="/home/investigator/downloads",
            filetypes=[
                ("All supported", "*.pdf *.docx *.doc *.xlsx *.xls"),
                ("PDF files", "*.pdf"),
                ("Word documents", "*.docx *.doc"),
                ("Excel files", "*.xlsx *.xls"),
                ("All files", "*.*")
            ]
        )
        if filename:
            self.doc_path_var.set(filename)
    
    def analyze_document(self):
        doc_path = self.doc_path_var.get()
        if not doc_path or not os.path.exists(doc_path):
            messagebox.showerror("Error", "Please select a valid document to analyze.")
            return
        
        self.doc_output.delete(1.0, tk.END)
        self.doc_output.insert(tk.END, f"Starting analysis of: {doc_path}\n")
        self.doc_output.insert(tk.END, f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        self.doc_output.insert(tk.END, "="*60 + "\n\n")
        
        # Run analysis in a separate thread
        threading.Thread(target=self._run_document_analysis, args=(doc_path,), daemon=True).start()
    
    def _run_document_analysis(self, doc_path):
        try:
            # Run the analysis script
            result = subprocess.run(
                ["/home/investigator/tools/analyze_document.sh", doc_path],
                capture_output=True,
                text=True,
                timeout=300
            )
            
            # Update GUI in main thread
            self.root.after(0, self._update_analysis_output, result.stdout, result.stderr)
            
        except subprocess.TimeoutExpired:
            self.root.after(0, self._update_analysis_output, "", "Analysis timed out after 5 minutes.")
        except Exception as e:
            self.root.after(0, self._update_analysis_output, "", f"Error running analysis: {str(e)}")
    
    def _update_analysis_output(self, stdout, stderr):
        if stdout:
            self.doc_output.insert(tk.END, stdout)
        if stderr:
            self.doc_output.insert(tk.END, f"\nErrors:\n{stderr}")
        self.doc_output.see(tk.END)
    
    def safe_view_document(self):
        doc_path = self.doc_path_var.get()
        if not doc_path or not os.path.exists(doc_path):
            messagebox.showerror("Error", "Please select a valid document to view.")
            return
        
        try:
            subprocess.Popen(["/home/investigator/tools/safe_view.sh", doc_path])
        except Exception as e:
            messagebox.showerror("Error", f"Failed to open document: {str(e)}")
    
    def investigate_url(self):
        url = self.url_var.get().strip()
        if not url:
            messagebox.showerror("Error", "Please enter a URL to investigate.")
            return
        
        self.url_output.delete(1.0, tk.END)
        self.url_output.insert(tk.END, f"Starting investigation of: {url}\n")
        self.url_output.insert(tk.END, f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        self.url_output.insert(tk.END, "="*60 + "\n\n")
        
        # Run investigation in a separate thread
        threading.Thread(target=self._run_url_investigation, args=(url,), daemon=True).start()
    
    def _run_url_investigation(self, url):
        try:
            result = subprocess.run(
                ["/home/investigator/tools/investigate_url.sh", url],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            self.root.after(0, self._update_url_output, result.stdout, result.stderr)
            
        except subprocess.TimeoutExpired:
            self.root.after(0, self._update_url_output, "", "Investigation timed out after 1 minute.")
        except Exception as e:
            self.root.after(0, self._update_url_output, "", f"Error running investigation: {str(e)}")
    
    def _update_url_output(self, stdout, stderr):
        if stdout:
            self.url_output.insert(tk.END, stdout)
        if stderr:
            self.url_output.insert(tk.END, f"\nErrors:\n{stderr}")
        self.url_output.see(tk.END)
    
    def browse_url_safe(self):
        url = self.url_var.get().strip()
        if not url:
            messagebox.showerror("Error", "Please enter a URL to browse.")
            return
        
        try:
            subprocess.Popen(["xfce4-terminal", "-e", f"lynx {url}"])
        except Exception as e:
            messagebox.showerror("Error", f"Failed to open browser: {str(e)}")
    
    def open_folder(self, path):
        try:
            subprocess.Popen(["thunar", path])
        except Exception as e:
            messagebox.showerror("Error", f"Failed to open folder: {str(e)}")
    
    def open_file_manager(self):
        try:
            subprocess.Popen(["thunar"])
        except Exception as e:
            messagebox.showerror("Error", f"Failed to open file manager: {str(e)}")
    
    def launch_app(self, app_name):
        try:
            subprocess.Popen([app_name])
        except Exception as e:
            messagebox.showerror("Error", f"Failed to launch {app_name}: {str(e)}")
    
    def refresh_results(self):
        # Clear existing items
        for item in self.results_tree.get_children():
            self.results_tree.delete(item)
        
        # Get investigation results
        investigations_dir = "/home/investigator/investigations"
        if os.path.exists(investigations_dir):
            try:
                for item in os.listdir(investigations_dir):
                    item_path = os.path.join(investigations_dir, item)
                    if os.path.isdir(item_path):
                        # Parse directory name to extract info
                        stat = os.stat(item_path)
                        date = datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M")
                        
                        if item.startswith("url_"):
                            inv_type = "URL"
                            target = "URL Investigation"
                        else:
                            inv_type = "Document"
                            target = item.replace("_", " ")
                        
                        status = "Complete"
                        
                        self.results_tree.insert("", "end", values=(date, inv_type, target, status))
            except Exception as e:
                print(f"Error reading investigations: {e}")
    
    def open_result(self, event):
        selection = self.results_tree.selection()
        if selection:
            item = self.results_tree.item(selection[0])
            target = item['values'][2]
            
            # Try to open the corresponding directory
            investigations_dir = "/home/investigator/investigations"
            for dir_name in os.listdir(investigations_dir):
                if target.replace(" ", "_") in dir_name:
                    self.open_folder(os.path.join(investigations_dir, dir_name))
                    break

def main():
    root = tk.Tk()
    app = InvestigationGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()