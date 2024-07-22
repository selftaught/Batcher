#!/usr/bin/env python3

import matplotlib.pyplot as plt
import argparse as ap
import json
import numpy as np


def plot(csv_file: str):
    with open(csv_file, 'r') as f:
        lines = [line.replace("\n", '') for line in f.readlines()]
        header = lines.pop(0)
        if not header:
            raise Exception("No header found in CSV file")
        res = {}
        curr_forks = None
        for line in lines:
            (io_ms_delay, forks, batch_count, batch_size, elapsed, t) = line.split(',')
            if curr_forks is None:
                curr_forks = forks
            elif curr_forks != forks:
                curr_forks = forks

            if curr_forks not in res.keys():
                res[curr_forks] = {'x': [], 'y': []}

            res[curr_forks]['x'].append(float(t))
            res[curr_forks]['y'].append(float(elapsed))

        print(json.dumps(res, indent=4))

        for fork_cnt, data in res.items():
            plt.plot(data['x'], data['y'], label=f'{fork_cnt} procs', marker='.')

        leg = plt.legend(bbox_to_anchor=(1.1, 1), loc = 'upper right', borderaxespad=0)
        plt.draw()
        plt.grid(True)
        plt.xlabel('Time')
        plt.ylabel('Time elapsed (milliseconds)')
        plt.show()


if __name__ == "__main__":
    parser = ap.ArgumentParser(description='Plot performance data points from csv')
    parser.add_argument('-f', '--file', help='csv input file')
    args = parser.parse_args()
    print(args)
    plot(csv_file=args.file)