# Testing ECS Exec

Run `terraform apply` to create the sample infra, and then test running a command inside the container:


```
0% aws ecs describe-services --cluster main --services ecs-exec | grep task
            "taskDefinition": "arn:aws:ecs:eu-west-1:262355063596:task-definition/ecs-exec:6",
                    "taskDefinition": "arn:aws:ecs:eu-west-1:262355063596:task-definition/ecs-exec:6",
                    "message": "(service ecs-exec) has started 1 tasks: (task 501baa96db6e41c2be390bf7d631aeba)."
0% aws ecs execute-command --cluster main \
    --task 501baa96db6e41c2be390bf7d631aeba \
    --container amazon-linux \
    --interactive \
    --command "/bin/sh"

The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.


Starting session with SessionId: ecs-execute-command-044e1413fda145ea9
sh-4.2# uname -a
Linux ip-172-31-4-218.eu-west-1.compute.internal 4.14.252-195.483.amzn2.x86_64 #1 SMP Mon Nov 1 20:58:46 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
sh-4.2#
```
