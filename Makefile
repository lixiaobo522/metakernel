# Note: This is meant for Metaernel developer use only
.PHONY: all clean test test_warn cover release gh-pages

export TEST_ARGS=--exe -v --with-doctest
export NAME=`python setup.py --name 2>/dev/null`
export VERSION=`python setup.py --version 2>/dev/null`
export GHP_MSG="Generated gh-pages for `git log master -1 --pretty=short --abbrev-commit`"

all: install

install: clean
	python setup.py install
	cd metakernel_python; python setup.py install
	cd metakernel_echo; python setup.py install
	cd metakernel_bash; python setup.py install

install3: clean
	python3 setup.py install
	cd metakernel_python; python3 setup.py install
	cd metakernel_echo; python3 setup.py install
	cd metakernel_bash; python3 setup.py install

clean:
	rm -rf build
	rm -rf dist
	/usr/bin/find . -name "*.pyc" -o -name "*.py,cover"| xargs rm -f

test: clean
	python setup.py build
	ipcluster2 start -n=3 &
	cd build; nosetests $(TEST_ARGS); ipcluster2 stop
	make clean

test_warn: clean
	python setup.py build
	ipcluster2 start -n=3 &
	export PYTHONWARNINGS="all"; cd build; nosetests $(TEST_ARGS); ipcluster2 stop
	make clean

cover: clean
	pip install nose-cov
	ipcluster2 start -n=3 &
	nosetests $(TEST_ARGS) --with-cov --cov $(NAME) $(NAME); ipcluster2 stop
	coverage annotate

release: 
	pip install wheel twine
	rm -rf dist
	python setup.py register
	python setup.py bdist_wheel --universal
	python setup.py sdist
	git commit -a -m "Release $(VERSION)"; true
	git tag v$(VERSION)
	git push origin --all
	git push origin --tags
	twine upload dist/*
	printf '\nUpgrade metakernel-feedstock with release and sha256 sum:'
	shasum -a 256 dist/*.tar.gz

gh-pages: clean
	pip install sphinx-bootstrap-theme numpydoc sphinx ghp-import
	git checkout master
	git pull origin master
	make -C docs html
	ghp-import -n -p -m $(GHP_MSG) docs/_build/html

help: 
	ipython console --kernel metakernel_python < generate_help.py
