function [Prices,Length]=cost(table,City)
      Prices = zeros(1,table.m);
      Length = zeros(1,table.m);
      for i = 1:table.m
          Single.table=table.Table(i,:);
          Single.table_load=table.Table_load(i,:);
          Single.sevice_time=table.Table_sevice_time(i,:);
          
          Prices(i)=cost4single(Single,City);
          table.m;
          %%
          Route = table.Table(i,:);
          
          for j = 1:(City.n+20 - 1)
              if Route(j+1)==0
                  break
              end
              Length(i) = Length(i) + City.Distance(Route(j),Route(j + 1));
          end
          
          Length(i) = Length(i) + City.Distance(Route(City.n),Route(1));
      end
end

      