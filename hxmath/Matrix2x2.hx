package hxmath;

// Note: All notation is column-major, e.g. m10 is the top element of the 2nd column
typedef Matrix2x2Shape = 
{
    // m00
    public var a:Float;
    
    // m10
    public var b:Float;
    
    // m01
    public var c:Float;
    
    // m11
    public var d:Float;
}

@:forward(a, b, c, d)
abstract Matrix2x2(Matrix2x2Shape) from Matrix2x2Shape to Matrix2x2Shape
{
    public static inline var elementCount:Int = 4;
    
    public static var zero(get, never):Matrix2x2;
    public static var identity(get, never):Matrix2x2;
    
    public var det(get, never):Float;
    public var transpose(get, never):Matrix2x2;

    // Note: parameters are in row-major order for syntactic niceness
    public function new(a:Float = 1.0, b:Float = 0.0, c:Float = 0.0, d:Float = 1.0) 
    {
        this = {
            a: a, b: b,
            c: c, d: d };
    }

    @:op(A * B)
    public static inline function multiplyScalar(s:Float, m:Matrix2x2):Matrix2x2
    {
        return new Matrix2x2(
            s * m.a, s * m.b,
            s * m.c, s * m.d);
    }
    
    @:op(A * B)
    public static inline function multiplyVector(m:Matrix2x2, v:Vector2):Vector2
    {
        return new Vector2(
            m.a * v.x + m.b * v.y,
            m.c * v.x + m.d * v.y);
    }
    
    @:op(A * B)
    public static inline function multiply(m:Matrix2x2, n:Matrix2x2):Matrix2x2
    {
        return new Matrix2x2(
            m.a * n.a + m.b * n.c,  // p_00 = m_i0 * n_0i
            m.a * n.b + m.b * n.d,  // p_10 = m_i0 * n_1i
            m.c * n.a + m.d * n.c,  // p_01 = m_i1 * n_0i
            m.c * n.b + m.d * n.d); // p_11 = m_i1 * n_1i
    }
    
    @:op(A + B)
    public static inline function add(m:Matrix2x2, n:Matrix2x2):Matrix2x2
    {
        return m.clone()
            .addWith(n);
    }
    
    @:op(A - B)
    public static inline function subtract(m:Matrix2x2, n:Matrix2x2):Matrix2x2
    {
        return m.clone()
            .subtractWith(n);
    }
    
    @:op(-A)
    public static inline function negate(m:Matrix2x2):Matrix2x2
    {
        return new Matrix2x2(
            -m.a, -m.b,
            -m.c, -m.d);
    }
    
    @:op(A == B)
    public static inline function equals(m:Matrix2x2, n:Matrix2x2):Bool
    {
        return
            m.a == n.a &&
            m.b == n.b &&
            m.c == n.c &&
            m.d == n.d;
    }
    
    @:op(A != B)
    public static inline function notEquals(m:Matrix2x2, n:Matrix2x2):Bool
    {
        return !(m == n);
    }
    
    public static inline function addWith(m:Matrix2x2, n:Matrix2x2):Matrix2x2
    {
        m.a += n.a;
        m.b += n.b;
        m.c += n.c;
        m.d += n.d;
        return m;
    }
    
    public static inline function subtractWith(m:Matrix2x2, n:Matrix2x2):Matrix2x2
    {
        m.a -= n.a;
        m.b -= n.b;
        m.c -= n.c;
        m.d -= n.d;
        return m;
    }
    
    /**
     * Counter-clockwise rotation.
     * 
     * @param angle     The angle to rotate (in radians).
     * @return          The rotation matrix.
     */
    public static inline function rotation(angle:Float):Matrix2x2
    {
        var s = Math.sin(angle);
        var c = Math.cos(angle);
        return new Matrix2x2(
             c, -s,
             s,  c);
    }
    
    /**
     * Non-uniform scale matrix.
     * 
     * @param sx    The amount to scale along the X axis.
     * @param sy    The amount to scale along the Y axis.
     * @return      The scale matrix.
     */
    public static inline function scale(sx:Float, sy:Float):Matrix2x2
    {
        return new Matrix2x2(
            sx, 0.0,
            0.0, sy);
    }
    
    public inline function clone():Matrix2x2
    {
        var self:Matrix2x2 = this;
        return new Matrix2x2(
            self.a, self.b,
            self.c, self.d
        );
    }
    
    @:arrayAccess
    public inline function getArrayElement(i:Int):Float
    {
        var row:Int = Math.floor(i / 2);
        var col:Int = i - row * 2;
        return getElement(col, row);
    }
    
    @:arrayAccess
    public inline function setArrayElement(i:Int, value:Float):Float
    {
        var row:Int = Math.floor(i / 2);
        var col:Int = i - row * 2;
        return setElement(col, row, value);
    }
    
    public inline function getElement(column:Int, row:Int):Float
    {
        var self:Matrix2x2 = this;
        var k:Float;

        switch [column, row]
        {
            case [0, 0]:
                k = self.a;
            case [1, 0]:
                k = self.b;
            case [0, 1]:
                k = self.c;
            case [1, 1]:
                k = self.d;
            default:
                throw "Invalid element";
        }
        
        return k;
    }
    
    public inline function setElement(column:Int, row:Int, value:Float):Float
    {
        var self:Matrix2x2 = this;
        
        switch [column, row]
        {
            case [0, 0]:
                self.a = value;
            case [1, 0]:
                self.b = value;
            case [0, 1]:
                self.c = value;
            case [1, 1]:
                self.d = value;
            default:
                throw "Invalid element";
        }
        
        return value;
    }
    
    public inline function col(index:Int):Vector2
    {
        var self:Matrix2x2 = this;
        
        switch (index)
        {
            case 0:
                return new Vector2(self.a, self.c);
            case 1:
                return new Vector2(self.b, self.d);
            default:
                throw "Invalid column";
        }
    }
        
    public inline function row(index:Int):Vector2
    {
        var self:Matrix2x2 = this;
        
        switch (index)
        {
            case 0:
                return new Vector2(self.a, self.b);
            case 1:
                return new Vector2(self.c, self.d);
            default:
                throw "Invalid row";
        }
    }
    
    /**
     * Apply a scalar function to each element.
     * 
     * @param func  The function to apply.
     * @return      The modified object.
     */
    public inline function applyScalarFunc(func:Float->Float):Matrix2x2
    {
        var self:Matrix2x2 = this;
        
        for (i in 0...4)
        {
            self[i] = func(self[i]);
        }
        
        return self;
    }
    
    private static inline function get_zero():Matrix2x2
    {
        return new Matrix2x2(
            0.0, 0.0,
            0.0, 0.0);
    }
    
    private static inline function get_identity():Matrix2x2
    {
        return new Matrix2x2(
            1.0, 0.0,
            0.0, 1.0);
    }
    
    private inline function get_det():Float
    {
        var self:Matrix2x2 = this;
        return MathUtil.det2x2(
            self.a, self.b,
            self.c, self.d);
    }
    
    private inline function get_transpose():Matrix2x2
    {
        var self:Matrix2x2 = this;
        return new Matrix2x2(
            self.a, self.c,
            self.b, self.d);
    }
}