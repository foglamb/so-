from setuptools import setup
from Cython.Build import cythonize
setup(
    ext_modules=cythonize(
        "dcjz_core.pyx",
        compiler_directives={"language_level": "3"},
        quiet=True
    ),
    script_args=["build_ext", "--inplace"]
)
