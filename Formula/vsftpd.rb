require 'formula'

class Vsftpd < Formula
  homepage 'https://security.appspot.com/vsftpd.html'
  url 'https://security.appspot.com/downloads/vsftpd-2.3.4.tar.gz'
  sha1 'b774cc6b4c50e20f4fe9ca7f6aa74169ce7fe5ea'

  option "openssl", "Build with OpenSSL"

  # Patch so vsftpd doesn't depend on UTMPX, and can't find OS X's PAM library.
  def patches; DATA; end

  def install
    if build.include? "openssl"
      inreplace "builddefs.h", "#undef VSF_BUILD_SSL", "#define VSF_BUILD_SSL"
    end

    inreplace "defs.h", "/etc/vsftpd.conf", "#{etc}/vsftpd.conf"
    inreplace "tunables.c", "/etc", etc
    inreplace "tunables.c", "/var", var
    system "make"

    # make install has all the paths hardcoded; this is easier:
    sbin.install "vsftpd"
    etc.install  "vsftpd.conf"
    man5.install "vsftpd.conf.5"
    man8.install "vsftpd.8"
  end

  def caveats
    if build.include? "openssl"
      return <<-EOD.undent
        vsftpd was compiled with SSL support. To use it you must generate a SSL
        certificate and set 'enable_ssl=YES' in your config file.
      EOD
    end
  end
end

__END__
diff --git a/sysdeputil.c b/sysdeputil.c
index 9dc8a5e..66dbe30 100644
--- a/sysdeputil.c
+++ b/sysdeputil.c
@@ -64,6 +64,10 @@
 #include <utmpx.h>
 
 /* BEGIN config */
+#if defined(__APPLE__)
+  #undef VSF_SYSDEP_HAVE_UTMPX
+#endif
+
 #if defined(__linux__)
   #include <errno.h>
   #include <syscall.h>
diff --git a/vsf_findlibs.sh b/vsf_findlibs.sh
index b988be6..68d4a34 100755
--- a/vsf_findlibs.sh
+++ b/vsf_findlibs.sh
@@ -20,6 +20,8 @@ if find_func pam_start sysdeputil.o; then
   locate_library /usr/lib/libpam.sl && echo "-lpam";
   # AIX ends shared libraries with .a
   locate_library /usr/lib/libpam.a && echo "-lpam";
+  # Mac OS X / Darwin shared libraries with .dylib
+  locate_library /usr/lib/libpam.dylib && echo "-lpam";
 else
   locate_library /lib/libcrypt.so && echo "-lcrypt";
   locate_library /usr/lib/libcrypt.so && echo "-lcrypt";
