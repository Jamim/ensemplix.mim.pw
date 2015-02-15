import os

from setuptools import setup, find_packages

requires = [
    'pyramid',
    'pyramid_chameleon',
    'pyramid_debugtoolbar',
    'mako',
    'waitress',
    ]

description='Статистика и вспомогательная информация Ensemplix'
setup(name='ensemplix',
      version='0.0.1a',
      description=description,
      long_description=description,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='Mim',
      author_email='mimworkmail@gmail.com',
      url='http://ensemplix.mim.pw',
      keywords='pyramid ensemplix',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      tests_require=requires,
      test_suite="ensemplix",
      entry_points="""\
      [paste.app_factory]
      main = ensemplix:main
      """,
      )
