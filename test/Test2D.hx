package test;

import hxmath.Matrix2x2;
import hxmath.Matrix3x2;
import hxmath.Vector2;
import hxmath.Vector3;

class Test2D extends MathTestCase
{
    public function testVector2BasicOps()
    {
        assertTrue(Vector2.xAxis * Vector2.yAxis == 0.0);
        assertTrue(0.0 * Vector2.xAxis == Vector2.zero);
    }
    
    public function testDeterminant()
    {
        assertTrue(Matrix2x2.identity.det == 1.0);
    }
    
    public function testHomogenousTranslation()
    {
        var m = Matrix3x2.identity;
        m.t = new Vector2(3, -1);
        assertTrue(m * Vector2.zero == m.t);
    }
    
    public function testTranspose()
    {
        var m = new Matrix2x2(
            Math.random(), Math.random(),
            Math.random(), Math.random());
        
        var n = m.transpose
            .transpose;
            
        var k = (m - n);
        var normSq = k.a * k.a + k.b * k.b + k.c * k.c + k.d * k.d;
        assertTrue(normSq < 1e-6);
    }
    
    public function testRowColAccessors()
    {
        var basis2 = [Vector2.xAxis, Vector2.yAxis];
        
        for (i in 0...2)
        {
            assertTrue(Matrix2x2.identity.col(i) == basis2[i]);
            assertTrue(Matrix2x2.identity.row(i) == basis2[i]);
        }
        
        var basis32Rows = [Vector3.xAxis, Vector3.yAxis];
        var basis32Cols = [Vector2.xAxis, Vector2.yAxis, Vector2.zero];
        
        for (i in 0...2)
        {
            assertTrue(Matrix3x2.identity.row(i) == basis32Rows[i]);
        }
        
        for (i in 0...3)
        {
            assertTrue(Matrix3x2.identity.col(i) == basis32Cols[i]);
        }
    }
    
    public function testRotation()
    {
        // After 90 degree ccw rotation:
        // x -> +y
        // y -> -x
        assertApproxEquals(((Matrix2x2.rotation(Math.PI / 2.0) * Vector2.xAxis) - Vector2.yAxis).length, 0.0);
        assertApproxEquals(((Matrix2x2.rotation(Math.PI / 2.0) * Vector2.yAxis) + Vector2.xAxis).length, 0.0);
    }
    
    public function testPolarConversion()
    {
        assertApproxEquals(0.0, (Vector2.fromPolar(Math.PI, 1.0) + Vector2.xAxis).length);
        assertApproxEquals(Math.PI, (-Vector2.xAxis).angle);
    }
}