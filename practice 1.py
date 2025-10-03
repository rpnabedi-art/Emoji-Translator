donations={"arpan":20,"arta":18,"jadi":12}
def donationa_analysis(don):
   person=''
   total=0
   count=0
   max_donation=-999999999999
   for name,value in don.items():
      total+=value
      count+=1
      if value>max_donation:
         person=name
         max_donation=value
   average=int(total/count)
   return average , total , person
avg,totall,max_person=donationa_analysis(donations)
print(f"total donations:{totall}")
print(f"average donations is{avg}")
print(f"thank for {max_person}")
   
