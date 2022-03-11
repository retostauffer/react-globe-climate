


dev:
	php -S localhost:8000


publish:
	scp index.html globe@eeecon.uibk.ac.at:~/public_html
	rsync -vaL js globe@eeecon.uibk.ac.at:~/public_html/
	rsync -vaL css globe@eeecon.uibk.ac.at:~/public_html/
	rsync -vaL js globe@eeecon.uibk.ac.at:~/public_html/
	rsync -vak tiles globe@eeecon.uibk.ac.at:~/public_html/


npm:
	npm install jquery
