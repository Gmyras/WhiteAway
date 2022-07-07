# WhiteAway

Part 1: Terraform code
I'm aware that the solution is lacking a lot like monitoring and alerting. LoadBalancing but I wanted to deliver as fast as possible. 

Part 2: Conceptualise and illustrate
  Now imagine that the development team asks for advice on:


  Which technology/product choices would you make and why?
  What advice would you give the developers on both subjects?
  What would the delivery pipeline look like? Please illustrate it.
  1. Building a delivery pipeline
   * Users commit code to a GitHub repo. 
   * Next AWS Code Pipeline fetches the code.
   * Start to build it and test it with AWS Code Build.
   * After sucessfull builds and tests AWS Code Deploy will update the applications running on AWS ECS.

![Alt](pipeline.drawio.png)
  2. Ensuring proper monitoring and high availability
   
 For proper monitoring and high availability I'd configure custom cloud watch alerts based on the most important metrics for the application. For avaliability I'd add Auto Scailing Groups to all avaliable Availability Zones with auto scaling based on the metrics from cloudwatch.
If we have the resources I would like to use DataDog for monionitoring and alerting. It provides veru usefull tracing functionallity that allows to troubleshoot any bottleneks in a more advance system. Also it give an overview of the whole infrastructure. 
