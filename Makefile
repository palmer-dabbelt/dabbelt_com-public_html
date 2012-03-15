.PHONY: all all-othermake

all: all-othermake

all-othermake:
	make -C ~/files/resume/general/

resume.pdf: ~/files/resume/general/resume.pdf
	cp ~/files/resume/general/resume.pdf .

resume.pdf.gpg: resume.pdf
	@rm resume.pdf.gpg 2> /dev/null || true
	gpg --sign --default-key 5311A5FF resume.pdf