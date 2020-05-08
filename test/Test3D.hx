package test;
import hxmath.math.DualQuaternion;
import hxmath.frames.Frame3;
import hxmath.math.MathUtil;
import hxmath.math.Matrix3x3;
import hxmath.math.Matrix4x4;
import hxmath.math.Quaternion;
import hxmath.math.Vector3;
import hxmath.math.Vector4;

class Test3D extends MathTestCase
{
    public function testMatrixMult()
    {
        for (i in 0...10)
        {
            var a = randomMatrix3x3();
            assertTrue(Matrix3x3.identity * a == a);
        }
    }
    
    public function testAddSub()
    {
        for (i in 0...10)
        {
            var a = randomMatrix3x3();
            var b = randomMatrix3x3();
            var c = a.clone();
            assertTrue((c.addWith(b)) == (a + b));
        }
        
        for (i in 0...10)
        {
            var a = randomMatrix3x3();
            var b = randomMatrix3x3();
            var c = a.clone();
            assertTrue((c.subtractWith(b)) == (a - b));
        }
    }
    
    public function testCrossProductPrecedence()
    {
        assertTrue(Vector3.xAxis + Vector3.yAxis % Vector3.zAxis == 2.0 * Vector3.xAxis);
    }
    
    public function testAxialRotation()
    {
        var quarterRot = 90.0;
        
        // After 90 degree ccw rotation around X:
        // y -> +z
        // z -> -y
        assertApproxEquals(((Matrix3x3.rotationX(quarterRot) * Vector3.yAxis) - Vector3.zAxis).length, 0.0);
        assertApproxEquals(((Matrix3x3.rotationX(quarterRot) * Vector3.zAxis) + Vector3.yAxis).length, 0.0);
        
        // After 90 degree ccw rotation around Y:
        // z -> +x
        // x -> -z
        assertApproxEquals(((Matrix3x3.rotationY(quarterRot) * Vector3.zAxis) - Vector3.xAxis).length, 0.0);
        assertApproxEquals(((Matrix3x3.rotationY(quarterRot) * Vector3.xAxis) + Vector3.zAxis).length, 0.0);
        
        // After 90 degree ccw rotation around Z:
        // x -> +y
        // y -> -x
        assertApproxEquals(((Matrix3x3.rotationZ(quarterRot) * Vector3.xAxis) - Vector3.yAxis).length, 0.0);
        assertApproxEquals(((Matrix3x3.rotationZ(quarterRot) * Vector3.yAxis) + Vector3.xAxis).length, 0.0);
    }
    
    public function testQuaternionToMatrix()
    {
        function createMatrixPair(unitAngle:Float, axis:Int)
        {
            var axes = [Vector3.xAxis, Vector3.yAxis, Vector3.zAxis];
            var const = [Matrix3x3.rotationX, Matrix3x3.rotationY, Matrix3x3.rotationZ];
            var angle = unitAngle * 360.0;
            var q = Quaternion.fromAxisAngle(angle, axes[axis]);
            var n = q.matrix;
            var m = const[axis](angle);
            
            return { m: m, n: n }
        }
        
        for (axis in 0...3)
        {
            var unitAngle:Float = 0.0;
            
            for (i in 0...10)
            {
                unitAngle += 0.01;
                var totalLength = 0.0;
                
                for (c in 0...3)
                {
                    var pair = createMatrixPair(unitAngle, axis);
                    totalLength += (pair.n.col(c) - pair.m.col(c)).length;
                }
                
                assertApproxEquals(totalLength, 0.0);
            }
        }
    }
    
    public function testMatrixFrameInverse()
    {
        for (i in 0...10)
        {
            // Create a non-degenerate frame
            var frame = randomFrame3();
            
            // Get the inverse (the matrix should be equivalent)
            var invFrame = frame.inverse();
            
            var frameMatrix = frame.matrix;
            
            // Both methods of inverting the frame should be equivalent
            var invFrameMatrix = invFrame.matrix;
            var frameMatrixInv = frame.matrix.applyInvertFrame();
            
            // A unit tetrahedron in 3D using homogenous points
            var homogenous0 = new Vector4(0.0, 0.0, 0.0, 1.0);
            var homogenousX = new Vector4(1.0, 0.0, 0.0, 1.0);
            var homogenousY = new Vector4(0.0, 1.0, 0.0, 1.0);
            var homogenousZ = new Vector4(0.0, 0.0, 1.0, 1.0);
            
            // The tetrahedron should be transformed identically by both matrices
            assertApproxEquals(0.0, (invFrameMatrix * homogenous0 - frameMatrixInv * homogenous0).lengthSq);
            assertApproxEquals(0.0, (invFrameMatrix * homogenousX - frameMatrixInv * homogenousX).lengthSq);
            assertApproxEquals(0.0, (invFrameMatrix * homogenousY - frameMatrixInv * homogenousY).lengthSq);
            assertApproxEquals(0.0, (invFrameMatrix * homogenousZ - frameMatrixInv * homogenousZ).lengthSq);
        }
    }
    
    public function testInverseMatrixFrameDualQuaternionInverse()
    {
        for (i in 0...10)
        {
            // Create a non-degenerate frame
            var dualQ_Frame3 = randomDualQuaternionAndFrame3();
            var frame = dualQ_Frame3.frame3;
            var dualQ = dualQ_Frame3.dualQ;
            
            // Get the inverse (the matrix should be equivalent)
            var invFrame = frame.inverse();
            var invDualQ = dualQ.invert();
            var frameMatrix = frame.matrix;
            var frameDualQ = dualQ.matrix;
            
            // Both methods of inverting the frame should be equivalent
            var invFrameMatrix = invFrame.matrix;
            var invDualQMatrix = invDualQ.matrix;
            var frameMatrixInv = frame.matrix.clone().applyInvertFrame();
            var dualQMatrixInv = dualQ.matrix.applyInvertFrame();
            
            // A unit tetrahedron in 3D using homogenous points
            var homogenous0 = new Vector4(0.0, 0.0, 0.0, 1.0);
            var homogenousX = new Vector4(1.0, 0.0, 0.0, 1.0);
            var homogenousY = new Vector4(0.0, 1.0, 0.0, 1.0);
            var homogenousZ = new Vector4(0.0, 0.0, 1.0, 1.0);
            
            // The tetrahedron should be transformed identically by both matrices
            assertApproxEquals(0.0, (invFrameMatrix * homogenous0 - frameMatrixInv * homogenous0).lengthSq);
            assertApproxEquals(0.0, (invFrameMatrix * homogenousX - frameMatrixInv * homogenousX).lengthSq);
            assertApproxEquals(0.0, (invFrameMatrix * homogenousY - frameMatrixInv * homogenousY).lengthSq);
            assertApproxEquals(0.0, (invFrameMatrix * homogenousZ - frameMatrixInv * homogenousZ).lengthSq);
            
            assertApproxEquals(0.0, (invDualQMatrix * homogenous0 - frameMatrixInv * homogenous0).lengthSq);
            assertApproxEquals(0.0, (invDualQMatrix * homogenousX - frameMatrixInv * homogenousX).lengthSq);
            assertApproxEquals(0.0, (invDualQMatrix * homogenousY - frameMatrixInv * homogenousY).lengthSq);
            assertApproxEquals(0.0, (invDualQMatrix * homogenousZ - frameMatrixInv * homogenousZ).lengthSq);
        }
    }

    public function testDualQuaternionInverse_Multiplication()
    {
        var dualQ = DualQuaternion.fromAxisAngle(90, Vector3.yAxis, new Vector4(10, 0, 0, 1));
        var dualQInv = dualQ.invert();
        var product = dualQ * dualQInv;
        assertApproxEquals(1.0, product.length);
        assertApproxEquals(1.0, product.real.s);
    }

    public function testDualQuaternionInverse_Basic()
    {
        // (Translate(10, 0, 0) * Rotate(90, y))^-1 =
        // Rotate(-90, y) * Translate(-Rotate(-90, y) * (10, 0, 0)) =
        // Rotate(-90, y) * Translate(0, 0, -10)
        var dualQ = DualQuaternion.fromAxisAngle(90, Vector3.yAxis, new Vector4(10, 0, 0, 1));

        var dualQInv = dualQ.invert();
        var dualQInvTranslation = dualQInv.getTranslation();
        var dualQInvRotation = dualQInv.real;

        assertApproxEquals(0.0, (dualQInvTranslation - new Vector4(0, 0, -10, 1)).length);
        assertApproxEquals(0.0, (dualQInvRotation - Quaternion.fromAxisAngle(-90, Vector3.yAxis)).length);

        var expectedMatrix = new Matrix4x4(
            0, 0, -1,   0,
            0, 1, 0,    0,
            1, 0, 0,   -10,
            0, 0, 0,    1
        );

        var dualQInvMatrix = dualQInv.matrix;

        assertApproxEquals(0.0, (dualQInvMatrix.col(0) - expectedMatrix.col(0)).length);
        assertApproxEquals(0.0, (dualQInvMatrix.col(1) - expectedMatrix.col(1)).length);
        assertApproxEquals(0.0, (dualQInvMatrix.col(2) - expectedMatrix.col(2)).length);
        assertApproxEquals(0.0, (dualQInvMatrix.col(3) - expectedMatrix.col(3)).length);
    }
    
    public function testMatrixFrameDualQuaternionInverse()
    {
        for (i in 0...10)
        {
            // Create a non-degenerate frame
            var dualQ_Frame3 = randomDualQuaternionAndFrame3();
            var frame = dualQ_Frame3.frame3;
            var dualQ = dualQ_Frame3.dualQ;
            
            var frameMatrix = frame.matrix;
            var frameDualQ = dualQ.matrix;
            
            // A unit tetrahedron in 3D using homogenous points
            var homogenous0 = new Vector4(0.0, 0.0, 0.0, 1.0);
            var homogenousX = new Vector4(1.0, 0.0, 0.0, 1.0);
            var homogenousY = new Vector4(0.0, 1.0, 0.0, 1.0);
            var homogenousZ = new Vector4(0.0, 0.0, 1.0, 1.0);
            
            // The tetrahedron should be transformed identically by both matrices
            
            assertApproxEquals(0.0, (frameMatrix * homogenous0 - frameDualQ * homogenous0).lengthSq);
            assertApproxEquals(0.0, (frameMatrix * homogenousX - frameDualQ * homogenousX).lengthSq);
            assertApproxEquals(0.0, (frameMatrix * homogenousY - frameDualQ * homogenousY).lengthSq);
            assertApproxEquals(0.0, (frameMatrix * homogenousZ - frameDualQ * homogenousZ).lengthSq);
        }
    }
    
    public function testQuaternionInverse()
    {
        for (i in 0...10)
        {
            var q = randomQuaternion().normal;
            var qInv = q.clone().applyConjugate();
            
            var p = q * qInv;
            
            assertApproxEquals(1.0, p.s);
            assertApproxEquals(0.0, new Vector3(p.x, p.y, p.z).length);
        }
    }
    
    public function testOrthoNormalize()
    {
        for (i in 0...10)
        {
            var u = randomVector3();
            var v = randomVector3();
            var w = randomVector3();
            
            Vector3.orthoNormalize(u, v, w);
            
            assertApproxEquals(1.0, u.length);
            assertApproxEquals(1.0, v.length);
            assertApproxEquals(1.0, w.length);
            assertApproxEquals(0.0, u * v);
            assertApproxEquals(0.0, u * w);
            assertApproxEquals(0.0, v * w);
            
            assertApproxEquals(0.0, ((u % v) % w).length);
        }
    }
    
    public function testAngles()
    {
        assertApproxEquals(Vector3.xAxis.angleWith(Vector3.yAxis), Math.PI / 2.0);
        assertApproxEquals(Vector3.xAxis.angleWith(Vector3.zAxis), Math.PI / 2.0);
        assertApproxEquals(Vector3.yAxis.angleWith(Vector3.zAxis), Math.PI / 2.0);
    }
    
    public function testReflect()
    {
        for (i in 0...10)
        {
            var u = randomVector3();
            var v = Vector3.reflect(u, Vector3.zAxis);
            
            assertEquals(u.x, v.x);
            assertEquals(u.y, v.y);
            assertEquals(-u.z, v.z);
        }
    }
    
    public function testProjectOntoPlane()
    {
        for (i in 0...10)
        {
            var u = randomVector3();
            var normal = randomVector3();
            
            u.projectOntoPlane(normal);
            
            assertApproxEquals(0.0, u * normal);
        }
    }
    
    public function testSlerpMidpointAngle()
    {
        var qA = Quaternion.fromAxisAngle(0, Vector3.zAxis);
        var qB = Quaternion.fromAxisAngle(90, Vector3.zAxis);
        var qC = Quaternion.slerp(qA, qB, 0.5);
        
        var angleAC = qA.angleWith(qC) * 180.0 / Math.PI;
        var angleCB = qC.angleWith(qB) * 180.0 / Math.PI;
        assertApproxEquals(45.0, angleAC);
        assertApproxEquals(45.0, angleCB);
    }
    
    public function testSlerpMonotonicity()
    {
        for (i in 0...10)
        {
            var qA = randomQuaternion().normalize();
            var qB = randomQuaternion().normalize();
            
            var lastAC = Math.NEGATIVE_INFINITY;
            var lastCB = Math.POSITIVE_INFINITY;
            
            for (step in 1...12)
            {
                var t = step / 12;
                var qC = Quaternion.slerp(qA, qB, t);
                var angleAC = qA.angleWith(qC) * 180.0 / Math.PI;
                var angleCB = qC.angleWith(qB) * 180.0 / Math.PI;
                
                assertTrue(angleAC > lastAC);
                assertTrue(angleCB < lastCB);
                lastAC = angleAC;
                lastCB = angleCB;
            }
        }
    }
    
    public function testSlerpLargeAngleStability()
    {
        var qA = Quaternion.fromAxisAngle(0, Vector3.zAxis);
        var qB = Quaternion.fromAxisAngle(180, Vector3.zAxis);
        var qC = Quaternion.slerp(qA, qB, 0.5);
        
        assertApproxEquals(90, qC.angleWith(qA) * 180.0 / Math.PI);
    }
    
    public function testSlerpSmallAngleStability()
    {
        var qA = Quaternion.fromAxisAngle(0, Vector3.zAxis);
        var qB = Quaternion.fromAxisAngle(1e-2, Vector3.zAxis);
        var qC = Quaternion.slerp(qA, qB, 0.5);
        
        assertTrue(qA.angleWith(qC) <= 1e-2);
    }
}