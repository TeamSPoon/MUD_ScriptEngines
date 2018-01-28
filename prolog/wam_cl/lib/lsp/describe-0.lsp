(in-package "SYSTEM")

(defun print-doc (symbol &optional (called-from-apropos-doc-p nil)
                         &aux (f nil) x (*notify-gbc* nil))
  (flet ((doc1 (doc ind) ; &aux (arglist (get symbol 'ARGLIST))
           (setq f t)
           (format t
                   "~&-----------------------------------------------------------------------------~%~53S~24@A~%~A"
                   symbol ind doc))
         (good-package ()
           (if (eq (symbol-package symbol) (find-package "LISP"))
               (find-package "SYSTEM")
               *package*)))

    (cond ((special-form-p symbol)
           (doc1 (or (documentation symbol 'FUNCTION) "")
                 (if (macro-function symbol)
                     "[Special form and Macro]"
                     "[Special form]")))
          ((macro-function symbol)
           (doc1 (or (documentation symbol 'FUNCTION) "") "[Macro]"))
          ((fboundp symbol)
           (doc1
            (or (documentation symbol 'FUNCTION)
                (if (consp (setq x (symbol-function symbol)))
                    (case (car x)
                          (LAMBDA (format nil "~%Args: ~S" (cadr x)))
                          (LAMBDA-BLOCK (format nil "~%Args: ~S" (caddr x)))
                          (LAMBDA-CLOSURE
                           (format nil "~%Args: ~S" (car (cddddr x))))
                          (LAMBDA-BLOCK-CLOSURE
                           (format nil "~%Args: ~S" (cadr (cddddr x))))
                          (t ""))
                    ""))
            "[Function]"))
          ((setq x (documentation symbol 'FUNCTION))
           (doc1 x "[Macro or Function]")))

    (cond ((constantp symbol)
           (unless (and (eq (symbol-package symbol) (find-package "KEYWORD"))
                        (null (documentation symbol 'VARIABLE)))
             (doc1 (or (documentation symbol 'VARIABLE) "") "[Constant]")))
          ((sys:specialp symbol)
           (doc1 (or (documentation symbol 'VARIABLE) "")
                 "[Special variable]"))
          ((or (setq x (documentation symbol 'VARIABLE)) (boundp symbol))
           (doc1 (or x "") "[Variable]")))

    (cond ((setq x (documentation symbol 'TYPE))
           (doc1 x "[Type]"))
          ((setq x (get symbol 'DEFTYPE-FORM))
           (let ((*package* (good-package)))
             (doc1 (format nil "~%Defined as: ~S~%See the doc of DEFTYPE." x)
                   "[Type]"))))

    (cond ((setq x (documentation symbol 'STRUCTURE))
           (doc1 x "[Structure]"))
          ((setq x (get symbol 'DEFSTRUCT-FORM))
           (doc1 (format nil "~%Defined as: ~S~%See the doc of DEFSTRUCT." x)
                 "[Structure]")))

    (cond ((setq x (documentation symbol 'SETF))
           (doc1 x "[Setf]"))
          ((setq x (get symbol 'SETF-UPDATE-FN))
           (let ((*package* (good-package)))
             (doc1 (format nil "~%Defined as: ~S~%See the doc of DEFSETF."
                           `(defsetf ,symbol ,(get symbol 'SETF-UPDATE-FN)))
                   "[Setf]")))
          ((setq x (get symbol 'SETF-LAMBDA))
           (let ((*package* (good-package)))
             (doc1 (format nil "~%Defined as: ~S~%See the doc of DEFSETF."
                           `(defsetf ,symbol ,@(get symbol 'SETF-LAMBDA)))
                   "[Setf]")))
          ((setq x (get symbol 'SETF-METHOD))
           (let ((*package* (good-package)))
             (doc1
              (format nil
                "~@[~%Defined as: ~S~%See the doc of DEFINE-SETF-METHOD.~]"
                (if (consp x)
                    (case (car x)
                          (LAMBDA `(define-setf-method ,@(cdr x)))
                          (LAMBDA-BLOCK `(define-setf-method ,@(cddr x)))
                          (LAMBDA-CLOSURE `(define-setf-method ,@(cddddr x)))
                          (LAMBDA-BLOCK-CLOSURE
                           `(define-setf-method ,@(cdr (cddddr x))))
                          (t nil))
                    nil))
            "[Setf]"))))
    )

  ;; Format of entries in file help.doc:
  ;; ^_[F | V | T]<name>
  ;; description
  ;; [@[F | V | T]<name>
  ;; other description]
  ;;
  ;; where F means Function, V Variable and T Type.
  ;;
  (let* ((name (symbol-name symbol))
	 (path (merge-pathnames *system-directory* "help.doc"))
	 (pos 0))

    (labels ((bin-search (file start end &aux (delta 0) (middle 0) sym)
	       (declare (fixnum start end delta middle))
	       (when (< start end)
		 (setq middle (round (+ start end) 2))
		 (file-position file middle)
		 (if (and (plusp (setq delta (scan-for #\^_ file)))
			  (<= delta (- end middle)))
		     (if (string-equal name
				       (setq sym (symbol-name (read file))))
			 (+ middle delta (length name) 1) ; skip EOL
			 (if (string< name sym)
			     (bin-search file start (1- middle))
			     (bin-search file (+ middle delta) end)))
		     (bin-search file start (1- middle)))))
	     (scan-for (char file)
	       (do ((v #\space (read-char file nil nil))
		    (n 0 (1+ n)))
		   ((eql v #\^_)
		    (if (read-char file nil nil) n -1))	; skip V | F | T.
		 (declare (fixnum n)))))

      (if (probe-file path)
	  (with-open-file (file path)
	    (setq pos (bin-search file 0 (file-length file)))
	    (when pos
	      (setq f t)
	      (file-position file pos)
	      (do (v)
		  ((eql (setq v (read-char file nil #\^_)) #\^_))
		(if (eql v #\ )
		    (progn
		      (terpri)
		      (read-char file nil nil))	; skip V | F | T.
		    (princ v)))))
	  (format t "~&Cannot find the help file \"help.doc\""))))

  (if called-from-apropos-doc-p
      f
      (progn (if f
                 (format t "~&-----------------------------------------------------------------------------")
                 (format t "~&No documentation for ~:@(~S~)." symbol))
             (values))))


