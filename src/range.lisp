
(in-package :relays-ui)

(rx:defm rx-div (&body body)
  `(rx:react-element :div ,@body))

(rx:defm rx-strong (&body body)
  `(rx:react-element :strong ,@body))

(rx:defm range-fn ()
  `(progn
     (defun get-percentage (current min max)
       (* 100 (/ (- current min) (- max min))))
     (defun get-value (percentage min max)
       (+ min (* percentage (/ (- max min) 100))))
     (defun get-left (percentage)
       (rx:js "`calc(${percentage}% - 5px)`"))
     (defun get-width (percentage)
       (rx:js "`${percentage}%`"))
     (defun format-fn (n)
       (when (= (ps:typeof n) "number") (ps:chain n (to-fixed 0))))
     (defun -range (props)
       (rx:js "const rangeRef = React.useRef()")
       (rx:js "const rangeProgressRef = React.useRef()")
       (rx:js "const thumbRef = React.useRef()")
       (rx:js "const currentRef = React.useRef()")
       (rx:js "const diff = React.useRef()")
       #|
       (setf (ps:@ props min)
         (or (ps:@ props min) 0))
       (unless (rx:@ props max)
         (setf (ps:@ props max) 100))
       (unless (rx:@ props format-fn)
         (setf (ps:@ props format-fn)
               (lambda (n) (ps:chain n (to-fixed 0)))))
       (unless (rx:@ props initial)
         (setf (ps:@ props initial) (format-fn (/ (- max min) 2))))
|#
       (let* ((initial-percentage
                (get-percentage (ps:@ props initial)
                                (ps:@ props min)
                                (ps:@ props max)))
              ;;(range-ref ((ps:@ -react use-ref)))
              ;;(range-progress-ref ((ps:@ -react use-ref)))
              ;;(thumb-ref ((ps:@ -react use-ref)))
              ;;(current-ref ((ps:@ -react use-ref)))
              ;;(diff ((ps:@ -react use-ref)))
              (handle-update
                ((ps:@ -react use-callback)
                 (lambda (v p)
                   (setf (ps:@ thumb-ref current style left)
                         (get-left p))
                   (setf (ps:@ range-progress-ref current style width)
                         (get-width p))
                   (setf (ps:@ current-ref current text-content)
                         (format-fn v))
                   nil)
                 (ps:array (ps:@ props format-fn))))
              (handle-mouse-move
                (lambda (e)
                  (let ((new-x (- (ps:@ e client-x)
                                  (ps:@ diff current)
                                  (ps:@ (ps:chain range-ref current
                                                  (get-bounding-client-rect))
                                        left)))
                        (end (- (ps:@ range-ref current offset-width)
                                (ps:@ thumb-ref current offset-width)))
                        (start 0))
                    (when (< new-x start) (setf new-x 0))
                    (when (> new-x end) (setf new-x end))
                    (let* ((new-percentage (get-percentage new-x start end))
                           (new-value (get-value new-percentage
                                                 (ps:@ props min)
                                                 (ps:@ props max))))
                      (handle-update new-value new-percentage)
                      ((ps:@ props on-change) new-value)))))
              (handle-mouse-up
                (lambda ()
                  (ps:chain document
                            (remove-event-listener "mouseup"
                                                   handle-mouse-up))
                  (ps:chain document
                            (remove-event-listener "mousemove"
                                                   handle-mouse-move))))
              (handle-mouse-down
                (lambda (e)
                  (setf (ps:@ diff current)
                        (- (ps:@ e client-x)
                           (ps:@ (ps:chain thumb-ref current
                                           (get-bounding-client-rect))
                                 left)))
                  (ps:chain document
                            (add-event-listener "mouseup"
                                                 handle-mouse-up))
                  (ps:chain document
                            (add-event-listener "mousemove"
                                                   handle-mouse-move)))))
         
         (rx:js "
const handleMouseUp = () => {
    document.removeEventListener('mouseup', handleMouseUp);
    document.removeEventListener('mousemove', handleMouseMove);
  };")
#|
         (ps:chain -react
                   (use-layout-effect
                    (lambda () (handle-update (ps:@ props initial) initial-percentage))
                    (ps:array (ps:@ props initial) initial-percentage handle-update)))
         |#
         (rx:js "
React.useLayoutEffect(() => {
    handleUpdate(props.initial, initialPercentage);
  }, [props.initial, initialPercentage, handleUpdate])
")
         (rx-div nil
                 (rx-div (rx:{} class-name "range-header")
                         (rx-div nil (format-fn (ps:@ props min)))
                         (rx-div nil
                                 (rx-strong (rx:{} ref current-ref))
                                 " / "
                                 (format-fn (ps:@ props max))))
                 (rx-div (rx:{} class-name "styled-range" ref range-ref)
                         (rx-div (rx:{} class-name "styled-range-progress"
                                        ref range-progress-ref))
                         (rx-div (rx:{} class-name "styled-thumb"
                                        ref thumb-ref
                                        on-mouse-down handle-mouse-down))))))))



