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

    [Header("Cone attributes")]
    [SerializeField]
    bool generateCone = false;
    [SerializeField]
    float coneHeight = 1f;
    [SerializeField]
    float coneRadius = 0.5f;
    [SerializeField]
    int coneSegments = 10;

    [Header("Materials")]
    [SerializeField]
    Material materialTemplate;


    void Start()
    {
        meshFilter = gameObject.AddComponent<MeshFilter>();
        meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshFilter.mesh = GenerateSphere();
        meshRenderer.sharedMaterial = materialTemplate;
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

        if (generateCone)
        {
            //front point of the sphere
            Vector3 sphereFront = new Vector3(0, 0, sphereRadius);

            // Generate Cone Base Vertices
            int coneBaseStartIndex = verts.Count;
            for (int i = 0; i < coneSegments; i++)
            {
                float angle = 2 * Mathf.PI * i / coneSegments;
                float x = coneRadius * Mathf.Cos(angle);
                float y = coneRadius * Mathf.Sin(angle);
                float z = sphereRadius; //Touching sphere
                verts.Add(new Vector3(x, y, z));
                normals.Add(new Vector3(x, y, 0).normalized);
            }

            // Cone Tip Vertex
            Vector3 coneTip = sphereFront + new Vector3(0, 0, coneHeight);
            verts.Add(coneTip);
            normals.Add((coneTip - sphereFront).normalized);

            // Cone Base Triangles
            for (int i = 0; i < coneSegments; i++)
            {
                int current = coneBaseStartIndex + i;
                int next = coneBaseStartIndex + (i + 1) % coneSegments;

                tris.Add(verts.Count - 1);
                tris.Add(next);
                tris.Add(current);
            }
        }

        // Assign to Mesh
        mesh.vertices = verts.ToArray();
        mesh.triangles = tris.ToArray();
        mesh.normals = normals.ToArray();

        return mesh;
    }
}
