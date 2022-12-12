using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProduceInstances : MonoBehaviour
{
    public GameObject prefab;
    public int row  = 20;
    public int column = 20;
    public float step = 2f;
    public Transform parent;
    private void OnEnable()
    {
        CheckParent();
        InstantiateChildren();
    }

    void CheckParent()
    {
        if (!parent)
        {
            GameObject parentGo = new GameObject();
            parent = parentGo.transform;    
        }
    }
    
    void InstantiateChildren()
    {
        if (parent && prefab)
        {
            for (int iz = 0; iz < row; iz++)
            {
                for (int ix = 0; ix < column; ix++)
                {
                    var inst = Instantiate(prefab);
                    var pos = new Vector3(ix * step ,0,iz * step);
                    inst.transform.position = pos;
                    inst.transform.SetParent(parent);
                }
            }
        }
       
    }

    void DestroyChildren()
    {
        if (parent)
        {
            if (parent.childCount > 0)
            {
                DestroyImmediate(parent.GetChild(0).gameObject);
            }
        }
    }

    public void OnDisable()
    {
        DestroyChildren();
        if (parent)
        {
            DestroyImmediate(parent.gameObject);    
        }
    }
}
