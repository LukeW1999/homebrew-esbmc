class Esbmc < Formula
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
  
  def install
    cd "esbmc-8.0"
    
    # Create a dedicated virtual environment for ESBMC's Python dependencies
    python3_bin = Formula["python@3.12"].opt_bin/"python3.12"
    
    # Create virtual environment
    system python3_bin, "-m", "venv", libexec
    
    # Install Python dependencies into the virtual environment
    system libexec/"bin"/"pip", "install", "--upgrade", "pip"
    system libexec/"bin"/"pip", "install", "meson", "ast2json", "mypy", "pyparsing", "toml", "tomli"
    
    # Use Python from virtual environment
    python3 = libexec/"bin"/"python3"
    ENV.prepend_path "PATH", libexec/"bin"
    args = %W[
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DLLVM_DIR=#{Formula["llvm"].opt_lib}/cmake/llvm
      -DClang_DIR=#{Formula["llvm"].opt_lib}/cmake/clang
      -DC2GOTO_SYSROOT=#{MacOS.sdk_path}
      -DPython3_EXECUTABLE=#{python3}
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
    
    # Create a wrapper script that sets up the Python virtual environment
    (bin/"esbmc").write <<~EOS
      #!/bin/bash
      export PATH="#{libexec}/bin:$PATH"
      export PYTHONPATH="#{libexec}/lib/python3.12/site-packages:$PYTHONPATH"
      exec "#{bin}/esbmc-bin" "$@"
    EOS
    chmod 0755, bin/"esbmc"
  end
  def caveats
    <<~EOS
      ESBMC Python frontend uses a dedicated virtual environment at:
        #{libexec}
      
      All Python dependencies (mypy, ast2json, etc.) are managed automatically.
      No additional user setup is required.
    EOS
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
