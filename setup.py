import setuptools

with open("README.md", "r") as fh:
  long_description = fh.read()

setuptools.setup(
    name='video2ppt',
    version='1.0.3',
    author="wudu",
    author_email="296525335@qq.com",
    description="Extract presentation slides from videos with accurate timestamps",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=['video2ppt', ],
    package_dir={'video2ppt': 'video2ppt'},
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    include_package_data=True,
    install_requires=[
        'click',
        'fpdf2',
        'matplotlib',
        'opencv-python',
        'numpy',
        'tqdm'
    ],
    entry_points='''
        [console_scripts]
        video2ppt=video2ppt:main
        v2p=video2ppt:main
    ''',
)