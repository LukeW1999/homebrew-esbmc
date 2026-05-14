class Esbmc < Formula
  desc "Efficient SMT-based context-bounded model checker for C, C++, and Python"
  homepage "https://esbmc.org"
  url "https://github.com/esbmc/esbmc/archive/refs/tags/v8.2.0.tar.gz"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
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
    python3 = Formula["python@3.12"].opt_bin/"python3.12"

    args = %W[
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DLLVM_DIR=#{Formula["llvm"].opt_lib}/cmake/llvm
      -DClang_DIR=#{Formula["llvm"].opt_lib}/cmake/clang
      -DC2GOTO_SYSROOT=#{MacOS.sdk_path}
      -DPython3_EXECUTABLE=#{python3}
      -DENABLE_CSMITH=ON
      -DENABLE_PYTHON_FRONTEND=ON
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
  end

  def caveats
    <<~EOS
      For Python type checking support, install mypy separately:
        brew install mypy
      Without mypy, ESBMC will still verify Python programs but skip type checking.
    EOS
  end

  test do
    assert_match "ESBMC version", shell_output("#{bin}/esbmc --version")

    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      int main() {
        int x = 5;
        assert(x == 5);
        return 0;
      }
    EOS
    system bin/"esbmc", "test.c", "--no-bounds-check", "--no-pointer-check"

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
