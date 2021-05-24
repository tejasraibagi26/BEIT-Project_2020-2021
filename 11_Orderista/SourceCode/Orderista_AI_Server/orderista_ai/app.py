from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.neighbors import NearestNeighbors
from scipy.sparse import csr_matrix
app = Flask(__name__)
CORS(app)


@app.route("/", methods=["GET"])
def hello():
    return "Hello World."


@app.route("/recommend", methods=["POST", "GET"])
def recommendation():
    print(request.json["itemId"])
    itemId = request.json["itemId"]
    try:
        menu_df = pd.read_csv('AI_Data.csv')
        rating_df = pd.read_csv('FoodRating.csv')
        df = pd.merge(rating_df, menu_df, on='foodid')
        rating_features_df = df.pivot_table(
            index='name', columns='userid', values='rating').fillna(0)
        rating_features_df_matrix = csr_matrix(rating_features_df.values)
        model_knn = NearestNeighbors(metric='cosine', algorithm='brute')
        model_knn.fit(rating_features_df_matrix)
        recos = []

        def recommend(index):
            query_index = index
            distances, indices = model_knn.kneighbors(
                rating_features_df.iloc[query_index, :].values.reshape(1, -1), n_neighbors=4)
            rating_features_df.head()
            indices.flatten()
            distances.flatten()
            for i in range(0, len(distances.flatten())):
                if i == 0:
                    print('Recommendations for {0}:\n'.format(
                        rating_features_df.index[query_index]))
                else:
                    recos.append(
                        rating_features_df.index[indices.flatten()[i]])
                    # print(recos)
                    # print('{0}: {1}, with distance of {2}:'.format(i, rating_features_df.index[indices.flatten()[i]], distances.flatten()[i]))

            return recos

        reco = recommend(int(itemId))

        return jsonify({
            "recommendation": reco,
            "msg": "Recommendation"
        })
    except Exception as e:
        return jsonify({
            "error": e
        })


if __name__ == '__main__':
    app.run(debug=True)
