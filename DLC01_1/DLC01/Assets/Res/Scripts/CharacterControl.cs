using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class CharacterControl : MonoBehaviour
{
	public float speedMultiplier = 3f;
	public Transform MainCamera;

	private Vector3 _inputVector;
	private Animator _animator;
	private Transform _transform;
	private Vector3 verticalOffset = new Vector3(0f, 0f, 0f);

	void Awake()
    {
        _animator = GetComponent<Animator>();
		_transform = GetComponent<Transform>();
    }

	private void Update()
	{
		float _hor = Input.GetAxis("Horizontal");
		float _ver = Input.GetAxis("Vertical");
		_inputVector = (new Vector3(_hor, 0f, _ver));

	}

	private void FixedUpdate()
	{
		if(_inputVector.sqrMagnitude > 1f)
		{
			_inputVector.Normalize();
		}

		if(_inputVector.sqrMagnitude != 0f)
		{
			Step(_inputVector);
		}
		else
		{
			_animator.SetBool("IsMoving", false);
		}
	}

    private void Step(Vector3 movementVector)
	{
		float input = movementVector.magnitude;
		Vector3 vDir = movementVector;
		if (MainCamera != null)
		{
			var forward = MainCamera.transform.forward;
			var right = MainCamera.transform.right;

			//project forward and right vectors on the horizontal plane (y = 0)
			forward.y = 0f;
			right.y = 0f;
			forward.Normalize();
			right.Normalize();

			//this is the direction in the world space we want to move:
			vDir = forward * _inputVector.z + right * _inputVector.x;
		}
		Vector3 newPosition = _transform.position + vDir * Time.deltaTime * speedMultiplier;
				
		NavMeshHit hit;
		NavMesh.SamplePosition(newPosition, out hit, .3f, NavMesh.AllAreas);
		bool hasMoved = (_transform.position - hit.position).magnitude >= .02f;
		
		if(hasMoved)
		{
			_transform.position = hit.position + verticalOffset;
			_animator.SetBool("IsMoving", hasMoved);
            _transform.forward = Vector3.Slerp(_transform.forward, vDir, Time.deltaTime * 7f);
        }
		else
		{
			//stops the animation when the character reaches the border of the NavMesh (even if input is still on)
			_animator.SetBool("IsMoving", false);
		}

		_animator.SetFloat("CurrentSpeed", input * speedMultiplier);
		
	}
}
