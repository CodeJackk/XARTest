using UnityEngine;

public class LissajousAnimator : MonoBehaviour
{
    [Header("Lissajous Parameters")]
    [SerializeField]
    Vector3 amplitude = new(5,5,5);
    [SerializeField]
    Vector3 frequency = new(1, 1, 1);
    [SerializeField]
    Vector3 phases = new(0f, Mathf.PI, Mathf.PI /2 );
    [SerializeField]
    float speed = 1f;
    
    [Header("Rotation Towards Target")]
    [SerializeField]
    bool enableRotation = false;
    [SerializeField]
    Transform target; //Target object
    [SerializeField]
    float angularSpeed = 90f; //degree/s
    

    private Vector3 startingPosition;
    private float time;

    Vector3 offset = new(0f,0f,0f);
    void Start()
    {
        // Store the initial position of the object
        startingPosition = transform.position;
    }

    void Update()
    {
        // Increment time based on speed
        time += Time.deltaTime * speed;

        // Compute position offset based on Lissajous curve equations
        for (int i = 0; i < 3;  i++)
        {
            offset[i] = amplitude[i] * Mathf.Sin(frequency[i] * time + phases[i]);
        }

        transform.position = startingPosition + offset;

        //rotate towards target
        if (enableRotation && !target)
        {
            RotateTowardsTarget();
        }
    }

    void RotateTowardsTarget()
    {
        //direction
        Vector3 directionToTarget = target.position - transform.position;

        //calc target rotation
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);

        //Lerp
        transform.rotation = Quaternion.RotateTowards(
            transform.rotation,
            targetRotation,
            angularSpeed * Time.deltaTime
        );
    }
}
