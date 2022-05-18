


dev:
	php -S localhost:8000


publish:
	scp index.html        globe@eeecon.uibk.ac.at:~/public_html/
	scp details.php       globe@eeecon.uibk.ac.at:~/public_html/
	scp locations.xml     globe@eeecon.uibk.ac.at:~/public_html/
	scp marker-icon.svg   globe@eeecon.uibk.ac.at:~/public_html/
	rsync -va  images     globe@eeecon.uibk.ac.at:~/public_html/
	rsync -vaL js         globe@eeecon.uibk.ac.at:~/public_html/
	rsync -vaL css        globe@eeecon.uibk.ac.at:~/public_html/
	rsync -vaL js         globe@eeecon.uibk.ac.at:~/public_html/
	rsync -ak tiles      globe@eeecon.uibk.ac.at:~/public_html/
	rsync -ak timeseries globe@eeecon.uibk.ac.at:~/public_html/


npm:
	npm install jquery
