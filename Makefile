.PHONY: all all-reentry clean

all:
	make -C ~/files/resume/general
	make all-reentry

clean:
	rm resume.pdf.gpg || true
	rm resume.pdf || true

all-reentry: resume.pdf.gpg

resume.pdf: ~/files/resume/general/resume.pdf
	cp ~/files/resume/general/resume.pdf .

resume.pdf.gpg: resume.pdf
	@rm resume.pdf.gpg 2> /dev/null || true
	gpg --sign --default-key 5311A5FF resume.pdf