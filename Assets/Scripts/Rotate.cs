using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public Transform target;
    public float speed = 10f;
    private void Update()
    {
        this.transform.RotateAround(target.position, Vector3.up, Time.deltaTime * speed);
    }
}
