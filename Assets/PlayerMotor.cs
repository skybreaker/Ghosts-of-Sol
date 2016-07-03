using UnityEngine;
using System.Collections;
using UnityEngine.UI;


[RequireComponent (typeof(Rigidbody))]
public class PlayerMotor : MonoBehaviour 
{
	public float lookTurnRate = 90f;
	public float rollRate = 90f;

	public float maxAirSupply = 100f;
	public float breathLength = 4f;
	public float airConsumedPerBreath = 1f; // the rate at which air is converted to thrust
	public Slider airBar;

	public float maxThrustSupply = 10f;
	public float thrustExhaustionRate = 3f;
	public Slider thrustBar;
	public float thrustForce = 1f;

	public Text debugTextField;

	private float airSupply;
	private float thrustSupply;

	public float AirSupply 
	{
		get 
		{
			return airSupply;
		}
		set 
		{
			airSupply = Mathf.Clamp(value, 0, maxAirSupply);
			airBar.normalizedValue = airSupply/maxAirSupply;
		}
	}

	public float ThrustSupply 
	{
		get 
		{
			return thrustSupply;
		}
		set 
		{
			thrustSupply = Mathf.Clamp(value, 0, maxThrustSupply);
			thrustBar.normalizedValue = thrustSupply/maxThrustSupply;
		}
	}

	private new Rigidbody rigidbody;

	// Use this for initialization
	void Start () 
	{
		SetCursorState(CursorLockMode.Locked);
		ThrustSupply = 0f;
		AirSupply = maxAirSupply;
		rigidbody = GetComponent<Rigidbody>();
	}

	float testFloat = 0;
	// Update is called once per frame
	void Update () 
	{
		//AirSupply -= airConsumedPerBreath*Time.deltaTime;
		//ThrustSupply += airConsumedPerBreath*Time.deltaTime;

		float breathDelta = Mathf.Sin((Time.time*Mathf.PI*2)/breathLength)*Mathf.PI;
		ThrustSupply += Mathf.Clamp(breathDelta, 0, float.MaxValue) * airConsumedPerBreath * Time.deltaTime/breathLength;
		AirSupply -= Mathf.Clamp(-breathDelta, 0, float.MaxValue) * airConsumedPerBreath * Time.deltaTime/breathLength;

		//debugTextField.text = ThrustSupply.ToString();

		transform.RotateAround(transform.position, transform.up, (Input.GetAxisRaw("Mouse X")/(float)Screen.width)*lookTurnRate);	
		transform.RotateAround(transform.position, transform.right, (-Input.GetAxisRaw("Mouse Y")/(float)Screen.width)*lookTurnRate);	
		transform.RotateAround(transform.position, transform.forward, -Input.GetAxisRaw("Roll")*rollRate*Time.deltaTime);	

		Vector3 thrustVector = transform.forward*Input.GetAxisRaw("Vertical") + transform.right*Input.GetAxisRaw("Horizontal") + transform.up*Input.GetAxisRaw("Lateral");
		thrustVector = Vector3.ClampMagnitude(thrustVector, 1f);
		rigidbody.AddForce(thrustVector*thrustForce, ForceMode.Acceleration);
		ThrustSupply -= thrustExhaustionRate*thrustVector.magnitude*Time.deltaTime;

		if(Input.GetKeyDown(KeyCode.Escape))
			SetCursorState(CursorLockMode.None);

		if(Input.GetMouseButtonDown(0))
			SetCursorState(CursorLockMode.Locked);
	}

	private void SetCursorState(CursorLockMode newState)
	{
		Cursor.lockState = newState;
		Cursor.visible = (newState != CursorLockMode.Locked);
	}
}
