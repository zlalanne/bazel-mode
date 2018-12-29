
;;; bazel-mode.el               -*- lexical-binding:t -*-

;; Copyright (C) 2018 Robert E. Brown.

;; Bazel Mode is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Bazel Mode is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Bazel Mode.  If not, see <http://www.gnu.org/licenses/>.

;; Author: Robert E. Brown <robert.brown@gmail.com>

(require 'cl)
(require 'python)

(defgroup bazel nil
  "Major mode for editing Bazel code."
  :group 'languages
  :link '(url-link "https://github.com/brown/bazel-mode"))

(defcustom bazel-mode-hook nil
  "Hook called by `bazel-mode'."
  :type 'hook
  :group 'bazel)

(defcustom buildifier-command (purecopy "buildifier")
  "The command used to format Bazel BUILD files."
  :type 'string
  :group 'bazel)

(defvar bazel-font-lock-keywords
  `(;; keywords
    ,(rx symbol-start
         (or "and" "break" "continue" "ctx" "def" "elif" "else" "fail" "for" "if" "in" "load"
             "not" "or" "pass" "return" "self")
         symbol-end)
    ;; function definitions
    (,(rx symbol-start "def" (1+ space) (group (1+ (or word ?_))))
     (1 font-lock-function-name-face))
    ;; constants from Runtime.java
    (,(rx symbol-start (or "False" "None" "True") symbol-end)
     . font-lock-constant-face)
    ;; built-in functions
    (,(rx symbol-start
          (or
           ;; Starlark.

           ;; from MethodLibrary.java
           "all" "any" "bool" "capitalize" "count" "dict" "dir" "elems" "endswith" "enumerate"
           "fail" "find" "format" "getattr" "hasattr" "hash" "index" "int" "isalnum" "isalpha"
           "isdigit" "islower" "isspace" "istitle" "isupper" "join" "len" "list" "lower" "lstrip"
           "max" "min" "partition" "print" "range" "replace" "repr" "reversed" "rfind" "rindex"
           "rpartition" "rsplit" "rstrip" "sorted" "split" "splitlines" "startswith" "str" "strip"
           "title" "tuple" "upper" "zip"
           ;; from BazelLibrary.java
           "depset" "select" "to_list" "type" "union"
           ;; from SkylarkRepositoryModule.java
           "repository_rule"
           ;; from SkylarkAttr.java
           "configuration_field"
           ;; from SkylarkRuleClassFunctions.java
           "Actions" "aspect" "DefaultInfo" "Label" "OutputGroupInfo" "provider" "rule" "struct"
           "to_json" "to_proto"
           ;; from PackageFactory.java
           "distribs" "environment_group" "exports_files" "glob" "licenses" "native" "package"
           "package_group" "package_name" "repository_name"
           ;; from WorkspaceFactory.java
           "register_execution_platforms" "register_toolchains" "workspace"
           ;; from SkylarkNativeModule.java but not also in PackageFactory.java
           "existing_rule" "existing_rules"
           ;; from searching Bazel's Java code for "BLAZE_RULES".
           "aar_import" "action_listener" "alias" "android_binary" "android_device"
           "android_instrumentation_test" "android_library" "android_local_test"
           "android_ndk_repository" "android_sdk_repository" "apple_binary" "apple_static_library"
           "apple_stub_binary" "bind" "cc_binary" "cc_import" "cc_library" "cc_proto_library"
           "cc_test" "config_setting" "constraint_setting" "constraint_value" "extra_action"
           "filegroup" "genquery" "genrule" "git_repository" "http_archive" "http_file" "http_jar"
           "j2objc_library" "java_binary" "java_import" "java_library" "java_lite_proto_library"
           "java_package_configuration" "java_plugin" "java_proto_library" "java_runtime"
           "java_runtime_suite" "java_test" "java_toolchain" "local_repository" "maven_jar"
           "maven_server" "new_git_repository" "new_http_archive" "new_local_repository"
           "objc_bundle" "objc_bundle_library" "objc_framework" "objc_import" "objc_library"
           "objc_proto_library" "platform" "proto_lang_toolchain" "proto_library" "py_binary"
           "py_library" "py_runtime" "py_test" "sh_binary" "sh_library" "sh_test" "test_suite"
           "toolchain" "xcode_config" "xcode_version"

           ;; Language rules.

           ;; Closure rules.
           "closure_css_binary" "closure_css_library" "closure_grpc_web_library"
           "closure_java_template_library" "closure_js_binary" "closure_js_deps"
           "closure_js_library" "closure_js_proto_library" "closure_js_template_library"
           "closure_js_test" "closure_proto_library" "closure_py_template_library" "phantomjs_test"
           ;; D rules.
           "d_binary" "d_docs" "d_library" "d_source_library" "d_test"
           ;; Docker rules.
           "container_bundle" "container_image" "container_import" "container_load"
           "container_pull" "container_push"
           "cc_image" "d_image" "go_image" "groovy_image" "java_image" "nodejs_image" "py3_image"
           "py_image" "rust_image" "scala_image" "war_image"
           ;; Go rules.
           "gazelle" "gazelle_dependencies"
           "go_binary" "go_context" "go_download_sdk" "go_embed_data" "go_host_sdk" "go_library"
           "go_local_sdk" "go_path" "go_proto_compiler" "go_proto_library" "go_register_toolchains"
           "go_repository" "go_rule" "go_rules_dependencies" "go_source" "go_test" "go_toolchain"
           ;; Groovy rules.
           "groovy_and_java_library" "groovy_binary" "groovy_junit_test" "groovy_library"
           "spock_test"
           ;; Kubernetes rules.
           "k8s_defaults" "k8s_object" "k8s_objects"
           ;; Rust rules.
           "rust_benchmark" "rust_binary" "rust_doc" "rust_doc_test" "rust_library" "rust_test"
           ;; Scala rules.
           "scala_binary" "scala_library" "scala_macro_library" "scala_test"
           "scalapb_proto_library"
           ;; Swift rules.
           "swift_binary" "swift_c_module" "swift_import" "swift_library" "swift_module_alias"
           "swift_proto_library" "swift_test")
          symbol-end)
     . font-lock-builtin-face)
    ;; TODO:  Handle assignments better.  The code below fontifies a[b] = 1 and a = b = 2.
    ,(nth 7 python-font-lock-keywords)
    ,(nth 8 python-font-lock-keywords)
    ))

(defvar bazel-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-f") 'bazel-format)
    map))

(define-derived-mode bazel-mode python-mode "Bazel"
  "Major mode for editing Bazel files.

\\{bazel-mode-map}"
  :group 'bazel

  (setq python-indent-guess-indent-offset nil
        python-indent-offset 4)

  ;; Replace Python keyword fontification with Skylark keyword fontification.
  (setq font-lock-defaults
        '(bazel-font-lock-keywords
          nil nil nil nil
          (font-lock-syntactic-face-function . python-font-lock-syntactic-face-function))))

(defun bazel-parse-diff-action ()
  (unless (looking-at (rx line-start
                          (group (+ digit)) (? ?, (group (+ digit)))
                          (group (| ?a ?d ?c))
                          (group (+ digit)) (? ?, (group (+ digit)))
                          line-end))
    (error "bad buildifier diff output"))
  (let* ((orig-start (string-to-number (match-string 1)))
         (orig-count (if (null (match-string 2))
                         1
                       (1+ (- (string-to-number (match-string 2)) orig-start))))
         (command (match-string 3))
         (formatted-count (if (null (match-string 5))
                              1
                            (1+ (- (string-to-number (match-string 5))
                                   (string-to-number (match-string 4)))))))
    (list command orig-start orig-count formatted-count)))

(defun bazel-patch-buffer (buffer diff-buffer)
  "Applies the diff editing actions contained in DIFF-BUFFER to BUFFER."
  (with-current-buffer buffer
    (save-restriction
      (widen)
      (goto-char (point-min))
      (let ((orig-offset 0)
            (current-line 1))
        (cl-flet ((goto-orig-line (orig-line)
                    (let ((desired-line (+ orig-line orig-offset)))
                      (forward-line (- desired-line current-line))
                      (setq current-line desired-line)))
                  (insert-lines (lines)
                    (dolist (line lines) (insert line))
                    (cl-incf current-line (length lines))
                    (cl-incf orig-offset (length lines)))
                  (delete-lines (count)
                    (let ((start (point)))
                      (forward-line count)
                      (delete-region start (point)))
                    (cl-decf orig-offset count)))
          (save-excursion
            (with-current-buffer diff-buffer
              (goto-char (point-min))
              (while (not (eobp))
                (cl-multiple-value-bind (command orig-start orig-count formatted-count)
                    (bazel-parse-diff-action)
                  (forward-line)
                  (cl-flet ((fetch-lines ()
                            (cl-loop repeat formatted-count
                                     collect (let ((start (point)))
                                               (forward-line 1)
                                               ;; Return only the text after "< " or "> ".
                                               (substring (buffer-substring start (point)) 2)))))
                    (cond ((equal command "a")
                           (let ((lines (fetch-lines)))
                             (with-current-buffer buffer
                               (goto-orig-line (1+ orig-start))
                               (insert-lines lines))))
                          ((equal command "d")
                           (forward-line orig-count)
                           (with-current-buffer buffer
                             (goto-orig-line orig-start)
                             (delete-lines orig-count)))
                          ((equal command "c")
                           (forward-line (+ orig-count 1))
                           (let ((lines (fetch-lines)))
                             (with-current-buffer buffer
                               (goto-orig-line orig-start)
                               (delete-lines orig-count)
                               (insert-lines lines)))))))))))))))

(defun bazel-format ()
  "Format the current buffer using buildifier."
  (interactive)
  (let ((input-file nil)
        (output-buffer nil)
        (errors-file nil))
    (unwind-protect
        (progn
          (setf input-file (make-temp-file "bazel-format-input-")
                output-buffer (get-buffer-create "*bazel-format-output*")
                errors-file (make-temp-file "bazel-format-errors-"))
          (write-region nil nil input-file nil 'silent-write)
          (with-current-buffer output-buffer (erase-buffer))
          (let ((status
                 (call-process buildifier-command nil `(,output-buffer ,errors-file) nil
                               "-mode=diff" input-file)))
            (case status
              ;; No reformatting needed or reformatting was successful.
              ((0 4)
               (save-excursion (bazel-patch-buffer (current-buffer) output-buffer))
               (let ((errors-buffer (get-buffer "*BazelFormatErrors*")))
                 (when errors-buffer (kill-buffer errors-buffer))))
              (t
               (case status
                 (1 (message "Starlark language syntax errors"))
                 (2 (message "buildifier invoked incorrectly or cannot run diff"))
                 (3 (message "buildifier encountered an unexpected run-time error"))
                 (t (message "unknown buildifier error")))
               (sit-for 1)
               (let ((build-file-name (file-name-nondirectory (buffer-file-name)))
                     (errors-buffer (get-buffer-create "*BazelFormatErrors*")))
                 (with-current-buffer errors-buffer
                   ;; A previously created compilation errors buffer is read only.
                   (setq buffer-read-only nil)
                   (erase-buffer)
                   (let ((coding-system-for-read "utf-8"))
                     (insert-file-contents-literally errors-file))
                   (when (= status 1)
                     ;; Replace the name of the temporary input file with that
                     ;; of the BUILD file we are saving in all syntax error
                     ;; messages.
                     (let ((regexp (rx-to-string `(sequence line-start (group ,input-file) ":"))))
                       (while (search-forward-regexp regexp nil t)
                         (replace-match build-file-name t t nil 1)))
                     ;; Use compilation mode so next-error can be used to find
                     ;; all the errors in the BUILD file.
                     (goto-char (point-min))
                     (compilation-mode)))
                 (display-buffer errors-buffer))))))
      (when input-file (delete-file input-file))
      (when output-buffer (kill-buffer output-buffer))
      (when errors-file (delete-file errors-file))
      )))

(provide 'bazel-mode)
