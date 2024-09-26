import emel/lazy/math/geometry
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/pair
import gleam/set.{type Set}
import gleam_zlists.{type ZList} as zlist

fn point_groups(
  points: ZList(ZList(Float)),
  centroids: ZList(ZList(Float)),
) -> ZList(#(ZList(Float), ZList(ZList(Float)))) {
  points
  |> ut_zlist.group_by(fn(x) {
    x
    |> geometry.nearest_neighbor(centroids)
    |> zlist.to_list
  })
  |> zlist.map(pair.map_first(_, zlist.of_list))
}

fn eager_set(centroids: ZList(ZList(Float))) -> Set(List(Float)) {
  centroids
  |> ut_zlist.to_list_of_lists
  |> set.from_list
}

fn iterate(
  temp_clusters: ZList(#(ZList(Float), ZList(ZList(Float)))),
) -> ZList(#(ZList(Float), ZList(ZList(Float)))) {
  let #(centroids, groups) = zlist.unzip(temp_clusters)
  let centroid_eager_set = eager_set(centroids)
  let new_centroids = zlist.map(groups, geometry.centroid)
  let new_centroid_eager_set = eager_set(new_centroids)
  case centroid_eager_set == new_centroid_eager_set {
    True -> temp_clusters
    False ->
      groups
      |> zlist.concat
      |> point_groups(new_centroids)
      |> iterate
  }
}

pub fn centroids_with_clusters(
  points: ZList(ZList(Float)),
  k: Int,
  seed: Int,
) -> ZList(#(ZList(Float), ZList(ZList(Float)))) {
  let centroids =
    points
    |> ut_zlist.uniq
    |> ut_zlist.shuffle(seed)
    |> zlist.take(k)
  points
  |> point_groups(centroids)
  |> iterate
}

pub fn clusters(
  points: ZList(ZList(Float)),
  k: Int,
  seed: Int,
) -> ZList(ZList(ZList(Float))) {
  centroids_with_clusters(points, k, seed)
  |> zlist.map(pair.second)
}

pub fn classifier(
  dataset: ZList(ZList(Float)),
  k: Int,
  seed: Int,
) -> fn(ZList(Float)) -> Int {
  let centroids: ZList(ZList(Float)) =
    dataset
    |> centroids_with_clusters(k, seed)
    |> zlist.map(pair.first)
  fn(xs) {
    zlist.indices()
    |> zlist.zip(centroids)
    |> ut_zlist.min_by(fn(t) {
      t
      |> pair.second
      |> geometry.euclidean_distance(xs)
    })
    |> ut_res.unsafe_res
    |> pair.first
  }
}
