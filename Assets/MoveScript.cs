using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveScript : MonoBehaviour
{
    public float speed = 1;
    private Vector3 vel = new Vector3( 0, 0, 0);
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if ( Input.GetKeyDown("s"))
        {
            vel.x = -1;
        }
        if (Input.GetKeyDown("w"))
        {
            vel.x = 1;
        }
        if (Input.GetKeyDown("a"))
        {
            vel.z = 1;
        }
        if (Input.GetKeyDown("d"))
        {
            vel.z = -1;
        }

        if (Input.GetKeyUp("s"))
        {
            vel.x = 0;
        }
        if (Input.GetKeyUp("w"))
        {
            vel.x = 0;
        }
        if (Input.GetKeyUp("a"))
        {
            vel.z = 0;
        }
        if (Input.GetKeyUp("d"))
        {
            vel.z = 0;
        }

        transform.position = transform.position + speed * Time.deltaTime * vel;
    }
}
