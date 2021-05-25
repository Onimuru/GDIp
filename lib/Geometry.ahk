;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#Requires AutoHotkey v2.0-a134-d3d43350

;======================================================  Include  ==============;

#Include %A_LineFile%\..\Math\Math.ahk

;===============  Class  =======================================================;

;Class Point2 {
;
;	;--------------- Method -------------------------------------------------------;
;	;-------------------------            General           -----;
;
;	;* Point2.Angle(point1 [Point2], point2 [Point2])
;	;* Description:
;		;* Calculate the angle from `point1` to `point2`.
;	Angle(point1, point2) {
;		Local
;		Global Math
;
;		x := -Math.ATan2({"x": point2.x - point1.x, "y": point2.y - point1.y})
;
;		return ((x < 0) ? (-x) : (Math.Tau - x))
;	}
;
;	;* Point2.Distance(point1 [Point2], point2 [Point2])
;	Distance(point1, point2) {
;		Local
;
;		return (Sqrt((point2.x - point1.x)**2 + (point2.y - point1.y)**2))
;	}
;
;	;* Point2.Equals(point1 [Point2], point2 [Point2])
;	Equals(point1, point2) {
;		Local
;
;		return (point1.x == point2.x && point1.y == point2.y)
;	}
;
;	;* Point2.Slope(point1 [Point2], point2 [Point2])
;	;* Note:
;		;* Two lines are parallel if their slopes are the same.
;		;* Two lines are perpendicular if their slopes are negative reciprocals of each other.
;	Slope(point1, point2) {
;		Local
;
;		return ((point2.y - point1.y)/(point2.x - point1.x))
;	}
;
;	;* Point2.MidPoint(point1 [Point2], point2 [Point2])
;	MidPoint(point1, point2) {
;		Local
;
;		return (super((point1.x + point2.x)/2, (point1.y + point2.y)/2))
;	}
;
;	;* Point2.Rotate(point1 [Point2], point2 [Point2], theta [Radians])
;	;* Description:
;		;* Calculate the coordinates of `point1` rotated around `point2`.
;	Rotate(point1, point2, theta) {
;		Local
;
;		c := Cos(theta), s := Sin(theta)
;			, x := point1.x - point2.x, y := point1.y - point2.y
;
;		return (super(x*c - y*s + point2.x, x*s + y*c + point2.y))
;	}
;
;	;-------------------------           Triangle           -----;  ;*** https://hratliff.com/files/curvature_calculations_and_circle_fitting.pdf || https://www.onlinemath4all.com/circumcenter-of-a-triangle.html
;
;	;* Point2.Circumcenter(point1 [Point2], point2 [Point2], point3 [Point2])
;	;* Description:
;		;* Calculate the circumcenter for three 2D points.
;	Circumcenter(point1, point2, point3) {
;		Local
;
;		x1 := point1.x, y1 := point1.y, x2 := point2.x, y2 := point2.y, x3 := point3.x, y3 := point3.y
;			, a := 0.5*((x2 - x1)*(y3 - y2) - (y2 - y1)*(x3 - x2))
;
;		if (a != 0) {
;			x := (((y3 - y1)*(y2 - y1)*(y3 - y2)) - ((x2**2 - x1**2)*(y3 - y2)) + ((x3**2 - x2**2)*(y2 - y1)))/(-4*a), y := (-1*(x2 - x1)/(y2 - y1))*(x - 0.5*(x1 + x2)) + 0.5*(y1 + y2)
;
;			return (super(x, y))
;		}
;
;		MsgBox("Failed: points are either collinear or not distinct")
;	}
;
;	;* Point2.Circumradius(point1 [Point2], point2 [Point2], point3 [Point2])
;	;* Description:
;		;* Calculate the circumradius for three 2D points.
;	Circumradius(point1, point2, point3) {
;		Local
;
;		x1 := point1.x, y1 := point1.y, x2 := point2.x, y2 := point2.y, x3 := point3.x, y3 := point3.y
;			, d := 2*((x2 - x1)*(y3 - y2) - (y2 - y1)*(x3 - x2))
;
;		if (d != 0) {
;			n := ((((x2 - x1)**2) + ((y2 - y1)**2))*((( x3 - x2)**2) + ((y3 - y2)**2))*(((x1 - x3)**2) + ((y1 - y3)**2)))**(0.5)
;
;			return (Abs(n/d))
;		}
;
;		MsgBox("Failed: points are either collinear or not distinct")
;	}
;
;	;-------------------------            Ellipse           -----;
;
;	;* Point2.Foci(EllipseObject)
;	Foci(ellipse) {
;		Local
;
;		f := ellipse.FocalLength
;			, o1 := (ellipse.Radius.a > ellipse.Radius.b)*f, o2 := (ellipse.Radius.a < ellipse.Radius.b)*f
;
;		return ([super(ellipse.h - o1, ellipse.k - o2), super(ellipse.h + o1, ellipse.k + o2)])
;	}
;
;	;* Point2.Epicycloid(EllipseObject1, EllipseObject2, (theta [Radians]))   ;*** Bad reference (oEllipse). Check formula
;	Epicycloid(ellipse1, ellipse2, theta := 0) {
;		return (super(ellipse1.h + (ellipse1.Radius + ellipse2.Radius)*Math.Cos(theta) - ellipse2.Radius*Math.Cos((ellipse1.Radius/ellipse2.Radius + 1)*theta), oEllipse.k - o[2], ellipse1.k + (ellipse1.Radius + ellipse2.Radius)*Math.Sin(theta) - ellipse2.Radius*Math.Sin((ellipse1.Radius/ellipse2.Radius + 1)*theta)))
;	}
;
;	;* Point2.Hypocycloid([EllipseObject1, EllipseObject2], (theta [Radians]))
;	Hypocycloid(ellipse1, ellipse2, theta := 0) {
;		return (super(ellipse1.h + (ellipse1.Radius - ellipse2.Radius)*Math.Cos(theta) + ellipse2.Radius*Math.Cos((ellipse1.Radius/ellipse2.Radius - 1)*theta), ellipse1.k + (ellipse1.Radius - ellipse2.Radius)*Math.Sin(theta) - ellipse2.Radius*Math.Sin((ellipse1.Radius/ellipse2.Radius - 1)*theta)))
;	}
;
;	;* Point2.OnEllipse(EllipseObject, (theta [Radians]))
;	;* Description:
;		;* Calculate the coordinates of a point on the circumference of an ellipse.
;	OnEllipse(ellipse, theta := 0) {
;		if (IsObject(ellipse.Radius)) {
;			t := Math.Tan(theta), o := [ellipse.Radius.a*ellipse.Radius.b, Sqrt(ellipse.Radius.b**2 + ellipse.Radius.theta**2*t**2)], s := (90 < theta && theta <= 270) ? (-1) : (1)
;
;			return (super(ellipse.h + (o[0]/o[1])*s, ellipse.k + ((o[0]*t)/o[1])*s))
;		}
;		return (super(ellipse.h + ellipse.Radius*Math.Cos(theta), ellipse.k + ellipse.Radius*Math.Sin(theta)))
;	}
;}
;------------------------------------------------------- Vector ---------------;

#Include *i%A_LineFile%\..\Geometry\Vec2.ahk
#Include *i%A_LineFile%\..\Geometry\Vec3.ahk
#Include *i%A_LineFile%\..\Geometry\Vec4.ahk

;------------------------------------------------------- Matrix ---------------;

#Include *i%A_LineFile%\..\Geometry\Matrix3.ahk
#Include *i%A_LineFile%\..\Geometry\RotationMatrix.ahk
#Include *i%A_LineFile%\..\Geometry\TransformMatrix.ahk

;-------------------------------------------------------  Shape  ---------------;

#Include *i%A_LineFile%\..\Geometry\Ellipse.ahk
#Include *i%A_LineFile%\..\Geometry\Rect.ahk