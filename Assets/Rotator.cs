using UnityEngine;
using System.Collections;

public class Rotator : MonoBehaviour 
{	
	public Vector3 angularVelocity;

	// Use this for initialization
	void Start () 
	{
	
	}
	
	// Update is called once per frame
	void Update () 
	{
		transform.Rotate(angularVelocity * Time.deltaTime);
	}
}
