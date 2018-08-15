#!/bin/bash

echo "This will setup a new PenTest Notebook"

read -p "Enter output directory (/root/Documents/HTB, /root/Documents/OSCP, ex): " DESTDIR

#git clone https://github.com/aviaryan/SublimeNotebook.git /opt/SublimeNotebook
cd /opt/SublimeNotebook
git pull

cp -R /opt/SublimeNotebook $DESTDIR
echo $DESTDIR

mkdir -p $DESTDIR/Targets

file=$DESTDIR/notebook.sublime-project; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
{
	"build_systems":
	[
		{
			"linux":
			{
				"shell_cmd": "gnome-terminal -e './manager.py; exec bash\"'"
			},
			"name": "manager.py",
			"osx":
			{
				"shell_cmd": "open -a Terminal.app ${project_path}"
			},
			"windows":
			{
				"cmd":
				[
					"start",
					"cmd",
					"/k",
					"python manager.py"
				],
				"shell": true
			},
			"working_dir": "${project_path}"
		}
	],
	"folders":
	[
		{
			"file_exclude_patterns":
			[
				"*.pyc",
				"////sublime_notebook/*.py",
				".gitignore",
				"LICENSE",
				"README.markdown",
				"manager.py",
				"notebook.sublime-project",
				"sublime_notebook/__init__.py",
				"sublime_notebook/cryptlib.py",
				"sublime_notebook/message.py",
				"sublime_notebook/settings.py",
				"sublime_notebook/sublime_notebook.py",
				"notebook.sublime-project.bkup"
			],
			"folder_exclude_patterns":
			[
				"__pycache__",
				".release",
				"////sublime_notebook/pyaes",
				"sublime_notebook",
				"sublime_notebook/docs",
				"sublime_notebook/pyaes"
			],
			"path": "."
		}
	],
	"settings":
	{
		"margin": 20,
		"word_wrap": true
	}
}
EOF