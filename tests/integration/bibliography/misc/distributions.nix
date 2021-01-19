{
  nixpkgsPath =
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/75dd59019ca3043d29ec6fbb3f69d9bcb46d2113.tar.gz";
      sha256 = "05i09d8nr04zcd33bribwzmk9xqy829h43z8qrpah4izqlv943vd";
    };
  nixJvmPath = builtins.fetchTarball {
    url = "https://github.com/nyraghu/nix-jvm/archive/094db47b7918258d8a4e6db9ad4c4909eee085b8.tar.gz";
    sha256 = "0dng0yl88kp2ad49l6fg18hnixlz8hn3z1244vlnq6yhps5i9qgl";
  };
  nixMiscellanyPath = builtins.fetchTarball {
    url = "https://github.com/nyraghu/nix-miscellany/archive/14853116d5b97e2e3096560b21c4595909d3ef6d.tar.gz";
    sha256 = "126x7x0qs3vp8yjghjskfxp92ibb3hpj92v1avyhxr2zffmqdk3g";
  };
  nixPythonPath = builtins.fetchTarball {
    url = "https://github.com/nyraghu/nix-python/archive/1b8e506325176af190d6ffd167d83513a7dbf7c6.tar.gz";
    sha256 = "0amfd6nwy6jxhh70wgzcr142lf3nrjb1vjb9cw2gk53m4ni9vrm5";
  };
  texmfPath = builtins.fetchTarball {
    url = "https://github.com/nyraghu/texmf/archive/d39a022d92cffbb2824aeaeb4fa37804fccdfe61.tar.gz";
    sha256 = "1da2pxgnqxhmfnzarxb6c9qkr7x2xbbpvwrp15hglay1yd4didsk";
  };
}
