using System.Collections.Generic;
using UnityEngine;
using static UnityEditor.Searcher.SearcherWindow.Alignment;

public class GenerateModel : MonoBehaviour
{
    MeshFilter meshFilter;
    MeshRenderer meshRenderer;

    [Header("Sphere attributes")]
    [SerializeField]
    int sphereSegments = 20;
    [SerializeField]
    int sphereRings = 10;
    [SerializeField]
    float sphereRadius = 1f;

    void Start()
    {
        meshFilter = gameObject.AddComponent<MeshFilter>();
        meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshFilter.mesh = GenerateSphere();
    }

    void Update()
    {
        
    }

    Mesh GenerateSphere()
    {
        Mesh mesh = new Mesh();

        var verts = new List<Vector3>();
        var tris = new List<int>();
        var normals = new List<Vector3>();

        //Calculate sphere
        for (int i = 0; i <= sphereRings; i++)
        {
            float theta = Mathf.PI * i / sphereRings;
            for (int j = 0; j <= sphereSegments; j++)
            {
                float phi = 2 * Mathf.PI * j / sphereSegments;
                float x = sphereRadius * Mathf.Sin(theta) * Mathf.Cos(phi);
                float z = sphereRadius * Mathf.Cos(theta); // Align to Z-axis
                float y = sphereRadius * Mathf.Sin(theta) * Mathf.Sin(phi);
                //Vertex
                verts.Add(new Vector3(x, y, z));
                //Normal dir
                normals.Add(new Vector3(x, y, z).normalized);

                // Sphere Triangles
                if (i < sphereRings && j < sphereSegments)
                {
                    int current = i * (sphereSegments + 1) + j;
                    int next = current + sphereSegments + 1;

                    tris.Add(current);
                    tris.Add(next);
                    tris.Add(current + 1);

                    tris.Add(current + 1);
                    tris.Add(next);
                    tris.Add(next + 1);
                }
            }
        }

        // Assign to Mesh
        mesh.vertices = verts.ToArray();
        mesh.triangles = tris.ToArray();
        mesh.normals = normals.ToArray();

        return mesh;
    }
}
