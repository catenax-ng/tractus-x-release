#!/user/bin/sh

#WORK_DIR="charts/tractusx-development"
WORK_DIR="."

echo $WORK_DIR

if [ -f "index.yaml" ]
then
    rm "index.yaml"
fi

for product_index_file in $(cat "$WORK_DIR/product-chart-index.yaml" | yq eval '.product-charts[].url' -)
do  
    if [ ! -f "act-product.yaml" ]
    then
        MERGE_FILE="template.yaml" 
    else
        MERGE_FILE="index.yaml"   
    fi

    echo "getting product chart index file at: $product_index_file"
    curl -LsS -o "$WORK_DIR/act-product.yaml" $product_index_file

    yq eval-all '. as $item ireduce ({}; . * $item )' $MERGE_FILE "$WORK_DIR/act-product.yaml" > temp_index.yaml

    mv temp_index.yaml index.yaml
    
done

# Set actual date, yq own date function doesn't work for older version (< 4.18 )
# yq eval -i '.generated = now' index.yaml
NOW=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)
yq eval -i '.generated = $NOW' index.yaml

rm act-product.yaml