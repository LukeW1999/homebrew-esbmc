class Esbmc < Formula
  include Language::Python::Virtualenv

  desc "Context-Bounded Model Checker for C/C++/Python programs"
  homepage "https://esbmc.org"
  url "https://github.com/esbmc/esbmc/archive/refs/tags/v8.0.tar.gz"
  sha256 "75506d4ee82e2d5fcc3173059561b7636226671a8a856addcc8246347d5fa01a"
  license "Apache-2.0"
  head "https://github.com/esbmc/esbmc.git", branch: "master"

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "csmith" => :build
  depends_on "flex" => :build
  depends_on "ninja" => :build
  depends_on "boost"
  depends_on "fmt"
  depends_on "gmp"
  depends_on "llvm"
  depends_on "nlohmann-json"
  depends_on "python@3.12"
  depends_on "yaml-cpp"
  depends_on "z3"

  # Python dependencies as resources (required for Homebrew/core)
  # Generated using: poet --resources meson ast2json mypy pyparsing toml tomli
  resource "ast2json" do
    url "https://files.pythonhosted.org/packages/2b/dc/7c11f80a782f051beafcc4707dd54888e7fcdeea5afa9236aa2e2cfa7073/ast2json-0.4.tar.gz"
    sha256 "b5cc42e97c29b77845b5d4ec32e74dcac538fb4c61a7faa570964bc96b19aeb7"
  end

  resource "librt" do
    url "https://files.pythonhosted.org/packages/e7/24/5f3646ff414285e0f7708fa4e946b9bf538345a41d1c375c439467721a5e/librt-0.7.8.tar.gz"
    sha256 "1a4ede613941d9c3470b0368be851df6bb78ab218635512d0370b27a277a0862"
  end

  resource "meson" do
    url "https://files.pythonhosted.org/packages/1b/d3/8c43e758cf456273c32652bb8b7a4ec2d74327d8849856b0b714ad671da7/meson-1.10.1.tar.gz"
    sha256 "c42296f12db316a4515b9375a5df330f2e751ccdd4f608430d41d7d6210e4317"
  end

  resource "mypy" do
    url "https://files.pythonhosted.org/packages/f5/db/4efed9504bc01309ab9c2da7e352cc223569f05478012b5d9ece38fd44d2/mypy-1.19.1.tar.gz"
    sha256 "19d88bb05303fe63f71dd2c6270daca27cb9401c4ca8255fe50d1d920e0eb9ba"
  end

  resource "mypy-extensions" do
    url "https://files.pythonhosted.org/packages/a2/6e/371856a3fb9d31ca8dac321cda606860fa4548858c0cc45d9d1d4ca2628b/mypy_extensions-1.1.0.tar.gz"
    sha256 "52e68efc3284861e772bbcd66823fde5ae21fd2fdb51c62a211403730b916558"
  end

  resource "pathspec" do
    url "https://files.pythonhosted.org/packages/fa/36/e27608899f9b8d4dff0617b2d9ab17ca5608956ca44461ac14ac48b44015/pathspec-1.0.4.tar.gz"
    sha256 "0210e2ae8a21a9137c0d470578cb0e595af87edaa6ebf12ff176f14a02e0e645"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/f3/91/9c6ee907786a473bf81c5f53cf703ba0957b23ab84c264080fb5a450416f/pyparsing-3.3.2.tar.gz"
    sha256 "c777f4d763f140633dcb6d8a3eda953bf7a214dc4eff598413c070bcdc117cbc"
  end

  resource "toml" do
    url "https://files.pythonhosted.org/packages/be/ba/1f744cdc819428fc6b5084ec34d9b30660f6f9daaf70eead706e3203ec3c/toml-0.10.2.tar.gz"
    sha256 "b3bda1d108d5dd99f4a20d24d9c348e91c4db7ab1b749200bded2f839ccbe68f"
  end

  resource "tomli" do
    url "https://files.pythonhosted.org/packages/82/30/31573e9457673ab10aa432461bee537ce6cef177667deca369efb79df071/tomli-2.4.0.tar.gz"
    sha256 "aa89c3f6c277dd275d8e243ad24f3b5e701491a860d5121f2cdd399fbb31fc9c"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/72/94/1a15dd82efb362ac84269196e94cf00f187f7ed21c242792a923cdb1c61f/typing_extensions-4.15.0.tar.gz"
    sha256 "0cea48d173cc12fa28ecabc3b837ea3cf6f38c6d1136f85cbaaf598984861466"
  end

  def install
    # Create virtual environment using Homebrew's helper
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resources

    # Ensure build tools from virtual environment are available during build
    ENV.prepend_path "PATH", libexec/"bin"

    args = %W[
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DLLVM_DIR=#{Formula["llvm"].opt_lib}/cmake/llvm
      -DClang_DIR=#{Formula["llvm"].opt_lib}/cmake/clang
      -DC2GOTO_SYSROOT=#{MacOS.sdk_path}
      -DPython3_EXECUTABLE=#{libexec}/bin/python3
      -DENABLE_CSMITH=ON
      -DENABLE_PYTHON_FRONTEND=ON
      -DENABLE_SOLIDITY_FRONTEND=ON
      -DENABLE_JIMPLE_FRONTEND=ON
      -DENABLE_FUZZER=OFF
      -DENABLE_Z3=ON
      -DZ3_DIR=#{Formula["z3"].opt_lib}/cmake/z3
      -DENABLE_BOOLECTOR=OFF
      -DENABLE_BITWUZLA=OFF
      -DENABLE_GOTO_CONTRACTOR=OFF
      -DBUILD_STATIC=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Rename the original esbmc binary
    mv bin/"esbmc", bin/"esbmc-bin"

    # Create wrapper script with environment variables
    (bin/"esbmc").write_env_script bin/"esbmc-bin",
      PYTHONPATH: libexec/"lib/python3.12/site-packages",
      PATH:       "#{libexec}/bin:$PATH"
  end

  test do
    assert_match "ESBMC version", shell_output("#{bin}/esbmc --version")
    # Test C verification
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      int main() {
        int x = 5;
        assert(x == 5);
        return 0;
      }
    EOS
    system bin/"esbmc", "test.c", "--no-bounds-check", "--no-pointer-check"
    # Test Python frontend
    (testpath/"test.py").write <<~EOS
      def main():
          x: int = 5
          assert x == 5
      if __name__ == "__main__":
          main()
    EOS
    system bin/"esbmc", "test.py"
  end
end
