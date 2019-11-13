using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassGenerator : MonoBehaviour {

    public Mesh grassMesh;
    public Material grassMaterial;

    public int seed;
    public Vector2 size;
    [Range(1, 1023)]
    public int grassNum;

    public float startHeight = 1000;
    List<Matrix4x4> matrices;

    private void Awake()
    {
        //Mesh mesh = GetComponent<MeshFilter>().mesh;
        grassMesh.bounds.Expand(new Vector3(grassMesh.bounds.size.y, 0, grassMesh.bounds.size.y));
        grassMesh.bounds = new Bounds(grassMesh.bounds.center, new Vector3(2, 2, 2));
    }

    // Use this for initialization
    void Start ()
    {
        matrices = new List<Matrix4x4>(grassNum);
        Random.InitState(seed);
        for (int i = 0; i < grassNum; ++i)
        {
            Vector3 origin = transform.position;
            origin.y = startHeight;
            origin.x += size.x * Random.Range(-0.5f, 0.5f);
            origin.z += size.y * Random.Range(-0.5f, 0.5f);
            Ray ray = new Ray(origin, Vector3.down);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                Debug.Log("Hit!! " + i.ToString());
                origin = hit.point;
                Quaternion rot = Quaternion.identity;//Quaternion.AngleAxis(Random.Range(-180,180),new Vector3(0,1,0));
                matrices.Add(Matrix4x4.TRS(origin, rot, Vector3.one));
            }
        }
    }
	
	// Update is called once per frame
	void Update () {
        Graphics.DrawMeshInstanced(grassMesh, 0, grassMaterial, matrices);
	}
}
