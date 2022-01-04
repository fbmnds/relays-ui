
(in-package :relays-ui)

(rx:defm three-state-fn ()
  `(progn
     (defvar *max_points* 50000)
     (defvar *ac* (rx:{} pos (ps:new (-float32-array (* 3 *max_points*)))
                         color (ps:new (-float32-array (* 3 *max_points*)))
                         from-idx 0
                         to-idx 2
                         upper-idx *max_points*
                         tick-update t
                         data-update ps:false
                         mode :random-init
                         timestamp (ps:chain -date (now))
                         repeat t))))

(rx:defm three-init-fn ()
  `(progn
     (defvar renderer (ps:new (ps:chain -t-h-r-e-e (-web-g-l-renderer))))
     (defvar scene (ps:new (ps:chain -t-h-r-e-e (-scene))))
     (defvar fov 90)
     (defvar aspect (/ (ps:@ window inner-width)
                       (ps:@ window inner-height)))
     (defvar near 1)
     (defvar far 1000)
     (defvar camera (ps:new (ps:chain
                             -t-h-r-e-e
                             (-perspective-camera fov aspect near far))))
     (defvar controls (ps:new (ps:chain
                               -t-h-r-e-e
                               (-orbit-controls
                                camera
                                (ps:@ renderer dom-element)))))
     (defvar geometry (ps:new (ps:chain -t-h-r-e-e (-buffer-geometry))))
     (defvar material (ps:new (ps:chain -t-h-r-e-e (-line-basic-material
                                                    (rx:{} vertex-colors t
                                                           linewidth 2)))))
     (defvar line (ps:new (ps:chain -t-h-r-e-e (-line geometry material))))
     (defun render ()
       (ps:chain renderer (render scene camera)))
     (defun on-window-resize ()
       (setf (ps:@ camera aspect) (/ (ps:@ window inner-width)
                                     (ps:@ window inner-height)))
       (ps:chain camera (update-projection-matrix))
       (ps:chain renderer (set-size (ps:@ window inner-width)
                                    (ps:@ window inner-height))))
     (defun init ()
       (ps:chain renderer (set-pixel-ratio (ps:@ window device-pixel-ratio)))
       (ps:chain renderer (set-size (ps:@ window inner-width)
                                    (ps:@ window inner-height)))
       (ps:chain camera position (set 0 0 1000))
       (ps:chain controls (listen-to-key-events window))
       (setf (ps:@ controls min-distance) 100)
       (setf (ps:@ controls max-distance) 50000)
       (setf (ps:@ controls max-polar-angle) 1.6)
       (ps:chain geometry
                 (set-attribute "position"
                                (ps:new (ps:chain -t-h-r-e-e
                                                  (-buffer-attribute
                                                  (ps:@ *ac* pos) 3)))))
       (ps:chain geometry
                 (set-attribute "color"
                                (ps:new (ps:chain -t-h-r-e-e
                                                  (-buffer-attribute
                                                   (ps:@ *ac* color) 3)))))
       (ps:chain geometry (set-draw-range 0 2))
       (ps:chain scene (add line))
       (ps:chain window (add-event-listener "resize" on-window-resize))
       ps:undefined)))

(rx:defm three-update-fn (port)
  `(progn
     (defun random-positions ()
       (setf (ps:@ *ac* upper-idx) *max_points*)
       (let ((pos (ps:@ *ac* pos))
             (color (ps:@ *ac* color))
             x y z cx cy cz (r 30))
         (dotimes (i (ps:@ *ac* upper-idx))
           (if (= (ps:rem i 2500) 0)
               (setf x 0 y 0 z 0)
               (setf x (+ x (* (- (ps:chain -math (random)) 0.5) r))
                     y (+ y (* (- (ps:chain -math (random)) 0.5) r))
                     z (+ z (* (- (ps:chain -math (random)) 0.5) r))))
           (setf (ps:@ pos (* 3 i)) x
                 (ps:@ pos (+ (* 3 i) 1)) y
                 (ps:@ pos (+ (* 3 i) 2)) z)
           (when (= (ps:rem i 500) 0)
             (setf cx (+ (/ x r) 0.5)
                   cy (+ (/ y r) 0.5)
                   cz (+ (/ z r) 0.5)))
           (setf (ps:@ color (* 3 i)) cx
                 (ps:@ color (+ (* 3 i) 1)) cy
                 (ps:@ color (+ (* 3 i) 2)) cz))
         (setf (ps:@ line geometry attributes position array) pos)
         (setf (ps:@ line geometry attributes color array) color))
       (setf (ps:@ *ac* data-update) t))

     (defun tick ()
       (cond ((eql (ps:@ *ac* mode) :random-init)
              (setf (ps:@ *ac* tick-update) t)
              (setf (ps:@ *ac* from-idx) 0)
              (setf (ps:@ *ac* to-idx) 2)
              (setf (ps:@ *ac* upper-idx) *max_points*)
              (setf (ps:@ *ac* data-update) t)
              (setf (ps:@ *ac* repeat) t)
              (random-positions)
              (setf (ps:@ *ac* mode) :random))
             ((eql (ps:@ *ac* mode) :random)
              (setf (ps:@ *ac* to-idx) (1+ (ps:@ *ac* to-idx)))
              (when (and (ps:@ *ac* repeat)
                         (=  (ps:@ *ac* to-idx) (ps:@ *ac* upper-idx)))
                (random-positions)
                (setf (ps:@ *ac* data-update) t)
                (setf (ps:@ *ac* to-idx) 2))
              (ps:chain line geometry (set-draw-range (ps:@ *ac* from-idx)
                                                      (ps:@ *ac* to-idx))))
             ((eql (ps:@ *ac* mode) :csv-init)
              (setf (ps:@ *ac* timestamp) (ps:chain -date (now)))
              (setf (ps:@ *ac* from-idx) 0)
              (setf (ps:@ *ac* to-idx) 2)
              (setf (ps:@ *ac* repeat) ps:false)
              (ps:chain line geometry (set-draw-range (ps:@ *ac* from-idx)
                                                      (ps:@ *ac* to-idx)))
              (setf (ps:@ *ac* mode) :csv-tock))
             ((eql (ps:@ *ac* mode) :csv-tick)
              (when (> (ps:chain -date (now)) (ps:@ *ac* timestamp))
                (setf (ps:@ *ac* to-idx) (1+ (ps:@ *ac* to-idx)))
                (when (= (ps:@ *ac* to-idx) (ps:@ *ac* upper-idx))
                  (if (ps:@ *ac* repeat)
                      (setf (ps:@ *ac* to-idx) 2)
                      (setf (ps:@ *ac* mode) :csv-pause)))
                (when (eql (ps:@ *ac* mode) :csv-tick)
                  (setf (ps:@ *ac* tick-update) t)
                  (ps:chain line geometry (set-draw-range (ps:@ *ac* from-idx)
                                                          (ps:@ *ac* to-idx)))
                  (setf (ps:@ *ac* mode) :csv-tock))))
             ((eql (ps:@ *ac* mode) :csv-tock)
              (setf (ps:@ *ac* timestamp) (+ (ps:chain -date (now)) 500))
              (setf (ps:@ *ac* tick-update) ps:false)
              (setf (ps:@ *ac* mode) :csv-tick))
             (t nil)))))

(rx:defm three-fn (port)
  `(progn
     (three-state-fn)
     (three-init-fn)
     (three-update-fn ,port)
     (defun animate ()
       (request-animation-frame animate)
       (ps:chain controls (update))
       (tick)
       (when (ps:@ *ac* tick-update)
         (when (ps:@ *ac* data-update)
           (setf (ps:@ line geometry attributes position needs-update) t)
           (setf (ps:@ line geometry attributes color needs-update) t)
           (setf (ps:@ *ac* data-update) ps:false)))
       (ps:chain renderer (render scene camera)))
     (init)
     (random-positions)
     (animate)))

(rx:defm lines-fn ()
  `(progn
     (defun on-change-near (v)
       (when (> (ps:abs (- near v)) 1)
         (setf (ps:@ camera near) v)
         ((ps:@ camera update-projection-matrix))))
     (defun on-change-far (v)
       ;;((ps:@ console log) v)
       (when (> (ps:abs (- far v)) 50)
         (setf (ps:@ camera far) v)
         ((ps:@ camera update-projection-matrix))))
     (defun on-change-random ()
       (setf (ps:@ *ac* mode) :random-init))
     (defun on-change-csv ()
       (setf (ps:@ *ac* mode) :csv-init))
     (defun -lines (props)
       (rx:use-state "upper" 1000)
       (defun on-change-to-idx (v)
         (setf (ps:@ *ac* to-idx) v)
         (set-upper (ps:@ *ac* upper-idx)))
       (rx:div (rx:{} width (ps:@ window inner-width)
                      height (ps:@ window inner-height))
               (rx:button (rx:{} id "csv-data-btn"
                                 key "csv-data"
                                 class-name "btn btn-primary btn-lg"
                                 on-click on-change-csv)
                          "Load CSV data")
               (rx:button (rx:{} id "random-data-btn"
                                 key "random-data"
                                 class-name "btn btn-primary btn-lg"
                                 on-click on-change-random)
                          "Random data")
               (rx:div (rx:{} id "lines" key "lines"))
               (rx:react-element -range
                                 (rx:{} id "to-idx"
                                        key "to-idx"
                                        min 2
                                        max upper
                                        initial 2
                                        on-change on-change-to-idx))
               (rx:react-element -range
                                 (rx:{} id "near"
                                        key "near"
                                        min 0
                                        max 100
                                        initial near
                                        on-change on-change-near))
               (rx:react-element -range
                                 (rx:{} id "far"
                                        key "far"
                                        min 0
                                        max 10000
                                        initial far
                                        on-change on-change-far))))))


