using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class BBEditor : MonoBehaviour
{
    //[SerializeField]
    //private float extent;

    void Awake()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        //Debug.Log("Extent before: " + mesh.bounds.size);
        mesh.bounds.Expand(new Vector3(mesh.bounds.size.y, 0, mesh.bounds.size.y));
        mesh.bounds = new Bounds( mesh.bounds.center, new Vector3( 2, 2, 2 ) );
        //Debug.Log("Extent after: " + mesh.bounds.size);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
