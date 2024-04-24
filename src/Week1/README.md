#### build a mini blockchain by python
```python
python blockchain.py
```

mine endpoint: http://localhost:5005/mine
full chain endpoint: http://localhost:5005/chain

![chain screenshot](image.png)

step1: deploy Ownable with BigBank address
![pg1](image-6.png)

step2: call method with litter eth, will revert
![pg2](image-2.png)

step3: call method with 1 eth, will success
![pg3](image-3.png)

step4: 0xAB call withdraw will occur error
![p4](image-7.png)

step5: try to use ownable call bigbank withdraw,occur error
![p5](image-8.png)

step6: change manager address then call withdraw from ownable
![p6](image-9.png)
![p7](image-10.png)
