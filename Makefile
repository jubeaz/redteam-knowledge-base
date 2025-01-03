filename=redteam
list-gls:
	 grep -r gls --include="*.tex" .
pdf: 
	pdflatex ${filename}.tex
	pdflatex ${filename}.tex

clean-all:
	rm -f ${filename}.{ps,pdf,log,aux,out,dvi,bbl,blg,acn,acr,alg,glg,glo,gls,dlsdefs,idx,ilg,ind,toc,glsdefs}
	rm -f *-{glo,glg,gls}

clean:
	rm -f ${filename}.{ps,pdf,log,aux,out,dvi}
