class Swelo < Formula
  desc "Safely clean build artifacts, caches, Docker and SDKs on developer Macs"
  homepage "https://github.com/musacanminaz/swelo"
  url "https://github.com/musacanminaz/swelo/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "ac8a6e7c1fc60e542b93ff9e6b2750ea518e6ef70f5375dcf8e003a5e7718e73"
  license "MIT"
  head "https://github.com/musacanminaz/swelo.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    ldflags = "-s -w -X github.com/musacanminaz/swelo/internal/cli.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/swelo"
    generate_completions_from_executable(bin/"swelo", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/swelo --version")
    # dry run on an empty home must find nothing to delete and delete nothing
    (testpath/"Desktop/app/node_modules").mkpath
    (testpath/"Desktop/app/package.json").write "{}"
    ENV["HOME"] = testpath
    ENV["SWELO_LANG"] = "en"
    output = shell_output("#{bin}/swelo clean --only node --recent-days 0 --all </dev/null")
    assert_match "node_modules", output
    assert_path_exists testpath/"Desktop/app/node_modules"
  end
end
