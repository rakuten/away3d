/**
 * A particle animation node used to create a follow behaviour on a particle system.
 */
package away3d.animators.nodes;


import away3d.materials.compilation.ShaderRegisterElement;
import away3d.animators.data.AnimationRegisterCache;
import away3d.materials.passes.MaterialPassBase;
import away3d.animators.data.ParticlePropertiesMode;
import away3d.animators.states.ParticleFollowState;

class ParticleFollowNode extends ParticleNodeBase {

	/** @private */
	static public var FOLLOW_POSITION_INDEX:Int = 0;
	/** @private */
	static public var FOLLOW_ROTATION_INDEX:Int = 1;
	/** @private */
	public var _usesPosition:Bool;
	/** @private */
	public var _usesRotation:Bool;
	/** @private */
	public var _smooth:Bool;
	
	/**
	 * Creates a new <code>ParticleFollowNode</code>
	 *
	 * @param	[optional] usesPosition	 Defines wehether the individual particle reacts to the position of the target.
	 * @param	[optional] usesRotation	 Defines wehether the individual particle reacts to the rotation of the target.
	 * @param	[optional] smooth	 Defines wehether the state calculate the interpolated value.
	 */
	public function new(usesPosition:Bool = true, usesRotation:Bool = true, smooth:Bool = false) {
		_stateClass = ParticleFollowState;
		_usesPosition = usesPosition;
		_usesRotation = usesRotation;
		_smooth = smooth;
		super("ParticleFollow", ParticlePropertiesMode.LOCAL_DYNAMIC, ((_usesPosition && _usesRotation)) ? 6 : 3, ParticleAnimationSet.POST_PRIORITY);
	}

	/**
	 * @inheritDoc
	 */
	override public function getAGALVertexCode(pass:MaterialPassBase, animationRegisterCache:AnimationRegisterCache):String {

		//TODO: use Quaternion to implement this function
		var code:String = "";
		if (_usesRotation) {
			var rotationAttribute:ShaderRegisterElement = animationRegisterCache.getFreeVertexAttribute();
			animationRegisterCache.setRegisterIndex(this, FOLLOW_ROTATION_INDEX, rotationAttribute.index);
			var temp1:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			animationRegisterCache.addVertexTempUsages(temp1, 1);
			var temp2:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			animationRegisterCache.addVertexTempUsages(temp2, 1);
			var temp3:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			var temp4:ShaderRegisterElement = null;
			if (animationRegisterCache.hasBillboard) {
				animationRegisterCache.addVertexTempUsages(temp3, 1);
				temp4 = animationRegisterCache.getFreeVertexVectorTemp();
			}
			animationRegisterCache.removeVertexTempUsage(temp1);
			animationRegisterCache.removeVertexTempUsage(temp2);
			if (animationRegisterCache.hasBillboard) animationRegisterCache.removeVertexTempUsage(temp3);
			var len:Int = animationRegisterCache.rotationRegisters.length;
			var i:Int;
			
			//x axis
			code += "mov " + temp1 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "mov " + temp1 + ".x," + animationRegisterCache.vertexOneConst + "\n";
			code += "mov " + temp3 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "sin " + temp3 + ".y," + rotationAttribute + ".x\n";
			code += "cos " + temp3 + ".z," + rotationAttribute + ".x\n";
			code += "mov " + temp2 + ".x," + animationRegisterCache.vertexZeroConst + "\n";
			code += "mov " + temp2 + ".y," + temp3 + ".z\n";
			code += "neg " + temp2 + ".z," + temp3 + ".y\n";
			if (animationRegisterCache.hasBillboard) code += "m33 " + temp4 + ".xyz," + animationRegisterCache.positionTarget + ".xyz," + temp1 + "\n"
			else {
				code += "m33 " + animationRegisterCache.scaleAndRotateTarget + ".xyz," + animationRegisterCache.scaleAndRotateTarget + ".xyz," + temp1 + "\n";
				i = 0;
				while (i < len) {
					code += "m33 " + animationRegisterCache.rotationRegisters[i] + ".xyz," + animationRegisterCache.rotationRegisters[i] + "," + temp1 + "\n";
					i++;
				}
			}

			//y axis
			code += "mov " + temp1 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "cos " + temp1 + ".x," + rotationAttribute + ".y\n";
			code += "sin " + temp1 + ".z," + rotationAttribute + ".y\n";
			code += "mov " + temp2 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "mov " + temp2 + ".y," + animationRegisterCache.vertexOneConst + "\n";
			code += "mov " + temp3 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "neg " + temp3 + ".x," + temp1 + ".z\n";
			code += "mov " + temp3 + ".z," + temp1 + ".x\n";
			if (animationRegisterCache.hasBillboard) code += "m33 " + temp4 + ".xyz," + temp4 + ".xyz," + temp1 + "\n"
			else {
				code += "m33 " + animationRegisterCache.scaleAndRotateTarget + ".xyz," + animationRegisterCache.scaleAndRotateTarget + ".xyz," + temp1 + "\n";
				i = 0;
				while (i < len) {
					code += "m33 " + animationRegisterCache.rotationRegisters[i] + ".xyz," + animationRegisterCache.rotationRegisters[i] + "," + temp1 + "\n";
					i++;
				}
			}

			//z axis
			code += "mov " + temp2 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "sin " + temp2 + ".x," + rotationAttribute + ".z\n";
			code += "cos " + temp2 + ".y," + rotationAttribute + ".z\n";
			code += "mov " + temp1 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "mov " + temp1 + ".x," + temp2 + ".y\n";
			code += "neg " + temp1 + ".y," + temp2 + ".x\n";
			code += "mov " + temp3 + "," + animationRegisterCache.vertexZeroConst + "\n";
			code += "mov " + temp3 + ".z," + animationRegisterCache.vertexOneConst + "\n";
			if (animationRegisterCache.hasBillboard) {
				code += "Im33 " + temp4 + ".xyz," + temp4 + ".xyz," + temp1 + "\n";
				code += "sub " + temp4 + ".xyz," + temp4 + ".xyz," + animationRegisterCache.positionTarget + ".xyz\n";
				code += "add " + animationRegisterCache.scaleAndRotateTarget + ".xyz," + temp4 + ".xyz," + animationRegisterCache.scaleAndRotateTarget + ".xyz\n";
			}

			else {
				code += "m33 " + animationRegisterCache.scaleAndRotateTarget + ".xyz," + animationRegisterCache.scaleAndRotateTarget + ".xyz," + temp1 + "\n";
				i = 0;
				while (i < len) {
					code += "m33 " + animationRegisterCache.rotationRegisters[i] + ".xyz," + animationRegisterCache.rotationRegisters[i] + "," + temp1 + "\n";
					i++;
				}
			}

		}
		if (_usesPosition) {
			var positionAttribute:ShaderRegisterElement = animationRegisterCache.getFreeVertexAttribute();
			animationRegisterCache.setRegisterIndex(this, FOLLOW_POSITION_INDEX, positionAttribute.index);
			code += "add " + animationRegisterCache.scaleAndRotateTarget + ".xyz," + positionAttribute + "," + animationRegisterCache.scaleAndRotateTarget + ".xyz\n";
		}
		return code;
	}

	/**
	 * @inheritDoc
	 */
	public function getAnimationState(animator:IAnimator):ParticleFollowState {
		return cast(animator.getAnimationState(this), ParticleFollowState) ;
	}
}

