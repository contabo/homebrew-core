class Gitwatch < Formula
  desc "Watch a file or folder and automatically commit changes to a git repo easily"
  homepage "https://github.com/gitwatch/gitwatch"
  url "https://github.com/gitwatch/gitwatch/archive/refs/tags/v0.1.tar.gz"
  sha256 "ed52d5c799c19dc6f920f3625964bc4b4948b6f8929c289aece462304e419697"
  license "GPL-3.0-or-later"
  head "https://github.com/gitwatch/gitwatch.git"

  depends_on "coreutils"
  depends_on "fswatch"

  def install
    bin.install "gitwatch.sh" => "gitwatch"
  end

  test do
    repo = testpath/"repo"
    system "git", "init", repo
    pid = spawn "gitwatch", "-m", "Update", repo, pgroup: true
    sleep 5
    touch repo/"file"
    sleep 5
    begin
      assert_match "Update", shell_output("git -C #{repo} log -1")
    ensure
      Process.kill "TERM", -pid
    end
  end
end
